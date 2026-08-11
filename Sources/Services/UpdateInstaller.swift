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

    /// 下载 DMG 并校验 SHA-256，返回临时文件路径。
    func download(_ release: ReleaseInfo) async throws -> URL {
        let (tempURL, response) = try await URLSession.shared.download(for: URLRequest(url: release.dmgURL))
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

        // 安全替换：旧包改名备份 → 新包就位 → 删除备份；失败则回滚
        let backup = target.deletingLastPathComponent().appendingPathComponent("EasyLaunchPad.app.old")
        try? fileManager.removeItem(at: backup)
        try fileManager.moveItem(at: target, to: backup)
        do {
            try fileManager.moveItem(at: staging, to: target)
            try? fileManager.removeItem(at: backup)
        } catch {
            try? fileManager.moveItem(at: backup, to: target)
            throw UpdateError.installFailed(error.localizedDescription)
        }
        return true
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
