import AppKit
import Foundation

@MainActor
final class AppCatalog: ObservableObject {
    @Published private(set) var apps: [AppItem] = []
    @Published private(set) var hiddenRecords: [HiddenAppRecord] = []

    private var manualURLs: [URL] = []
    private var trashedIDs: Set<String> = []
    private let workspace = NSWorkspace.shared
    private let selfBundleID = Bundle.main.bundleIdentifier ?? ""

    init() {
        hiddenRecords = LaunchpadStore.loadHiddenApps()
        manualURLs = LaunchpadStore.loadManualURLs()
    }

    func refresh() {
        let hiddenIDs = Set(hiddenRecords.map(\.id))
        var byID: [String: AppItem] = [:]

        for item in scanApplicationsFolders() where !hiddenIDs.contains(item.id) && !trashedIDs.contains(item.id) {
            byID[item.id] = item
        }
        for url in manualURLs {
            guard let bundle = Bundle(url: url) else { continue }
            let id = bundle.bundleIdentifier ?? url.deletingPathExtension().lastPathComponent
            guard !hiddenIDs.contains(id), !trashedIDs.contains(id), byID[id] == nil else { continue }
            let name = displayName(for: bundle, fallback: url.deletingPathExtension().lastPathComponent)
            byID[id] = AppItem(id: id, name: name, url: url)
        }

        apps = byID.values
            .filter { $0.id != selfBundleID }
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

    // MARK: - Scanning

    private func scanApplicationsFolders() -> [AppItem] {
        var dirs: [String] = ["/Applications"]
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

    private func displayName(for bundle: Bundle, fallback: String) -> String {
        (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? fallback
    }
}
