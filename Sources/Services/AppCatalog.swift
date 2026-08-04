import AppKit
import Foundation

@MainActor
final class AppCatalog: ObservableObject {
    @Published private(set) var apps: [AppItem] = []
    @Published private(set) var hiddenRecords: [HiddenAppRecord] = []

    private var manualURLs: [URL] = []
    private var trashedIDs: Set<String> = []
    private let selfBundleID = Bundle.main.bundleIdentifier ?? ""
    private var refreshScheduled = false

    /// 是否扫描 /System/Applications（系统应用，如计算器）。
    var includeSystemApps = true

    init() {
        hiddenRecords = LaunchpadStore.loadHiddenApps()
        manualURLs = LaunchpadStore.loadManualURLs()
    }

    /// 合并同一事件循环内的多次刷新，目录扫描在后台执行，
    /// 主线程只做过滤合并与发布，避免动画期间卡顿。
    func refresh() {
        guard !refreshScheduled else { return }
        refreshScheduled = true
        Task { @MainActor in
            refreshScheduled = false
            await performRefresh()
        }
    }

    @MainActor
    private func performRefresh() async {
        let hiddenIDs = Set(hiddenRecords.map(\.id))
        let trashed = trashedIDs
        let manual = manualURLs
        let selfID = selfBundleID
        let includeSystem = includeSystemApps
        let newApps = await Task.detached(priority: .userInitiated) {
            Self.buildApps(
                hiddenIDs: hiddenIDs,
                trashed: trashed,
                manual: manual,
                selfID: selfID,
                includeSystemApps: includeSystem
            )
        }.value
        // 内容未变化时不发布，避免无谓动画
        if apps != newApps {
            apps = newApps
        }
    }

    private nonisolated static func buildApps(
        hiddenIDs: Set<String>,
        trashed: Set<String>,
        manual: [URL],
        selfID: String,
        includeSystemApps: Bool
    ) -> [AppItem] {
        var byID: [String: AppItem] = [:]
        for item in scanApplicationsFolders(includeSystemApps: includeSystemApps)
        where !hiddenIDs.contains(item.id) && !trashed.contains(item.id) {
            byID[item.id] = item
        }
        for url in manual {
            guard let bundle = Bundle(url: url) else { continue }
            let id = bundle.bundleIdentifier ?? url.deletingPathExtension().lastPathComponent
            guard !hiddenIDs.contains(id), !trashed.contains(id), byID[id] == nil else { continue }
            let name = displayName(for: bundle, fallback: url.deletingPathExtension().lastPathComponent)
            byID[id] = AppItem(id: id, name: name, url: url)
        }
        return byID.values
            .filter { $0.id != selfID }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - App management

    func hide(_ app: AppItem) {
        guard !hiddenRecords.contains(where: { $0.id == app.id }) else { return }
        hiddenRecords.append(HiddenAppRecord(id: app.id, name: app.name, url: app.url))
        LaunchpadStore.saveHiddenApps(hiddenRecords)
        refresh()
    }

    func unhide(_ id: String) {
        hiddenRecords.removeAll { $0.id == id }
        LaunchpadStore.saveHiddenApps(hiddenRecords)
        refresh()
    }

    func addManual(_ url: URL) {
        guard !manualURLs.contains(url) else { return }
        manualURLs.append(url)
        LaunchpadStore.saveManualURLs(manualURLs)
        refresh()
    }

    func removeManual(_ url: URL) {
        manualURLs.removeAll { $0 == url }
        LaunchpadStore.saveManualURLs(manualURLs)
        refresh()
    }

    func markTrashed(_ app: AppItem) {
        trashedIDs.insert(app.id)
        refresh()
    }

    // MARK: - Scanning (后台执行，非隔离)

    private nonisolated static func scanApplicationsFolders(includeSystemApps: Bool) -> [AppItem] {
        var dirs: [String] = ["/Applications"]
        if includeSystemApps {
            dirs.append("/System/Applications")
        }
        let home = NSHomeDirectory()
        dirs.append(home + "/Applications")
        var items: [AppItem] = []
        for dir in dirs {
            let url = URL(fileURLWithPath: dir, isDirectory: true)
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }
            for appURL in contents where appURL.pathExtension == "app" {
                guard let bundle = Bundle(url: appURL) else { continue }
                let id = bundle.bundleIdentifier ?? appURL.deletingPathExtension().lastPathComponent
                let name = displayName(for: bundle, fallback: appURL.deletingPathExtension().lastPathComponent)
                items.append(AppItem(id: id, name: name, url: appURL))
            }
        }
        return items
    }

    private nonisolated static func displayName(for bundle: Bundle, fallback: String) -> String {
        (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? fallback
    }
}
