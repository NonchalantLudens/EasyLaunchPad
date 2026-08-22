import Combine
import Foundation

/// 更新流程协调者：定时检查、下载、安装与状态发布。
@MainActor
final class UpdateManager: ObservableObject {
    enum State: Equatable {
        case idle
        case checking
        case updateAvailable(ReleaseInfo)
        case downloading(ReleaseInfo)
        case installing(ReleaseInfo)
        case upToDate
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var lastCheckedAt: Date?
    /// 当前下载进度（0…1），仅 downloading 状态有效。
    @Published private(set) var downloadProgress: Double = 0

    private let checker = UpdateChecker()
    private let installer = UpdateInstaller.shared
    private var timer: Timer?
    private var checkTask: Task<Void, Never>?

    var currentVersion: Version {
        Version(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0") ?? Version(major: 0, minor: 0, patch: 0)
    }

    /// 启动定时检查（启动时立即检查一次，之后每小时）。
    func startAutoCheck() {
        checkForUpdates(silent: true)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkForUpdates(silent: true)
        }
    }

    func stopAutoCheck() {
        timer?.invalidate()
        timer = nil
    }

    func checkForUpdates(silent: Bool = false) {
        guard state != .checking else { return }
        checkTask?.cancel()
        state = .checking
        checkTask = Task { [weak self] in
            guard let self else { return }
            do {
                let release = try await self.checker.fetchLatest()
                self.lastCheckedAt = Date()
                if release.version > self.currentVersion {
                    self.state = .updateAvailable(release)
                } else {
                    self.state = .upToDate
                }
            } catch {
                self.state = .failed(error.localizedDescription)
                if silent {
                    // 静默检查失败不打扰用户，回到空闲态
                    self.state = .idle
                }
            }
        }
    }

    func downloadAndInstall(_ release: ReleaseInfo) {
        guard installer.isUpdatable else {
            state = .failed("应用需安装在 /Applications 等可写位置才能自动更新")
            return
        }
        state = .downloading(release)
        downloadProgress = 0
        Task { [weak self] in
            guard let self else { return }
            do {
                let dmg = try await self.installer.download(release) { [weak self] fraction in
                    Task { @MainActor [weak self] in
                        self?.downloadProgress = min(max(fraction, 0), 1)
                    }
                }
                self.downloadProgress = 1
                self.state = .installing(release)
                try self.installer.install(from: dmg)
                self.installer.relaunch()
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
}
