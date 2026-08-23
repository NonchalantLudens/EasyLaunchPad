import AppKit
import CryptoKit
import Foundation

/// 下载、校验并安装更新（DMG 挂载 → 安全替换 → 重启）。
@MainActor
final class UpdateInstaller {
    static let shared = UpdateInstaller()

    private let fileManager = FileManager.default

    /// 应用是否位于可写位置（自动更新要求安装在 /Applications 等可写目录）。
    var isUpdatable: Bool {
        let bundleURL = Bundle.main.bundleURL
        return fileManager.isWritableFile(atPath: bundleURL.deletingLastPathComponent().path)
    }

    /// 流式下载 DMG（实时进度回调），校验 SHA-256 后返回本地文件路径。
    func download(_ release: ReleaseInfo, progressHandler: @escaping @Sendable (Double) -> Void) async throws -> URL {
        let delegate = ProgressDownloadDelegate(progressHandler: progressHandler)
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }

        let (tempURL, response): (URL, URLResponse) = try await withCheckedThrowingContinuation { continuation in
            delegate.continuation = continuation
            session.downloadTask(with: URLRequest(url: release.dmgURL)).resume()
        }
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UpdateError.network((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let data = try Data(contentsOf: tempURL)
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        guard digest.lowercased() == release.sha256.lowercased() else {
            throw UpdateError.checksumMismatch
        }
        let destination = fileManager.temporaryDirectory
            .appendingPathComponent("EasyLaunchPad-\(release.version).dmg")
        try? fileManager.removeItem(at: destination)
        try fileManager.moveItem(at: tempURL, to: destination)
        return destination
    }

    /// 挂载 DMG、提取应用、安全替换当前应用，返回是否成功。
    @discardableResult
    func install(from dmgURL: URL) throws -> Bool {
        let target = Bundle.main.bundleURL

        let base = fileManager.temporaryDirectory.appendingPathComponent("EasyLaunchPad-update-\(UUID().uuidString)")
        let mountPoint = base.appendingPathComponent("mnt")
        let staging = base.appendingPathComponent("EasyLaunchPad.app")
        try fileManager.createDirectory(at: mountPoint, withIntermediateDirectories: true)

        defer {
            detach(mountPoint)
            try? fileManager.removeItem(at: base)
        }

        // 挂载 DMG
        let attach = Process()
        attach.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        attach.arguments = ["attach", "-nobrowse", "-quiet", dmgURL.path, "-mountpoint", mountPoint.path]
        try attach.run()
        attach.waitUntilExit()
        guard attach.terminationStatus == 0 else { throw UpdateError.mountFailed }

        // 提取应用到暂存目录
        let mountedApp = mountPoint.appendingPathComponent("EasyLaunchPad.app")
        guard fileManager.fileExists(atPath: mountedApp.path) else { throw UpdateError.appNotFound }
        try fileManager.copyItem(at: mountedApp, to: staging)

        // 安全替换：唯一化备份名（避免与历史遗留目录冲突）→ 新包就位 → 清理；失败则回滚
        let backup = target.deletingLastPathComponent()
            .appendingPathComponent("EasyLaunchPad.app.old-\(UUID().uuidString)")
        try fileManager.moveItem(at: target, to: backup)
        do {
            try fileManager.moveItem(at: staging, to: target)
            try? fileManager.removeItem(at: backup)
            cleanupLegacyBackups(at: target.deletingLastPathComponent())
        } catch {
            try? fileManager.removeItem(at: backup)
            try? fileManager.moveItem(at: backup, to: target)
            throw UpdateError.installFailed(error.localizedDescription)
        }
        return true
    }

    /// 尽力清理历史版本的固定名备份目录（权限不足时静默跳过）。
    private func cleanupLegacyBackups(at directory: URL) {
        let legacyNames = [
            "EasyLaunchPad.app.old",
            "EasyLaunchPad.app.bak",
        ]
        for name in legacyNames {
            try? fileManager.removeItem(at: directory.appendingPathComponent(name))
        }
        if let contents = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey]
        ) {
            for url in contents where url.lastPathComponent.hasPrefix("EasyLaunchPad.app.bak-") {
                try? fileManager.removeItem(at: url)
            }
        }
    }

    /// 退出当前进程并重新启动新版本。
    func relaunch() {
        let appURL = Bundle.main.bundleURL
        let script = "sleep 1; open \"\(appURL.path)\""
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", script]
        try? task.run()
        NSApp.terminate(nil)
    }

    private func detach(_ mountPoint: URL) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        task.arguments = ["detach", "-quiet", mountPoint.path]
        try? task.run()
        task.waitUntilExit()
    }
}

/// URLSession 下载委托：转发实时进度，桥接 async/await 结果。
private final class ProgressDownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    let progressHandler: @Sendable (Double) -> Void
    var continuation: CheckedContinuation<(URL, URLResponse), Error>?
    private var downloadedURL: URL?

    init(progressHandler: @escaping @Sendable (Double) -> Void) {
        self.progressHandler = progressHandler
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent("EasyLaunchPad-download-\(UUID().uuidString).dmg")
        try? FileManager.default.removeItem(at: destination)
        try? FileManager.default.moveItem(at: location, to: destination)
        downloadedURL = destination
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        progressHandler(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            continuation?.resume(throwing: error)
            continuation = nil
        } else if let downloadedURL, let response = task.response {
            continuation?.resume(returning: (downloadedURL, response))
            continuation = nil
        } else {
            continuation?.resume(throwing: UpdateError.installFailed("下载未产生文件"))
            continuation = nil
        }
    }
}
