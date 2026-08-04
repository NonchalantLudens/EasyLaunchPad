import AppKit
import Foundation

@MainActor
final class AppCatalog: ObservableObject {
    @Published private(set) var apps: [AppItem] = []

    private let workspace = NSWorkspace.shared
    private let selfBundleID = Bundle.main.bundleIdentifier ?? ""

    func refresh() {
        var byID: [String: AppItem] = [:]
        for item in scanLaunchServices() {
            byID[item.id] = item
        }
        for item in scanFileSystem() {
            if byID[item.id] == nil {
                byID[item.id] = item
            }
        }
        apps = byID.values
            .filter { $0.id != selfBundleID }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func scanLaunchServices() -> [AppItem] {
        guard let cls = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type,
              let lsWorkspace = cls.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject,
              let proxies = lsWorkspace.perform(Selector(("allApplications")))?.takeUnretainedValue() as? [NSObject]
        else {
            return []
        }
        return proxies.compactMap { proxy -> AppItem? in
            guard let id = proxy.value(forKey: "bundleIdentifier") as? String, !id.isEmpty else { return nil }
            let name: String = {
                guard let raw = proxy.value(forKey: "localizedName") as? String, !raw.isEmpty else { return id }
                return raw
            }()
            let url = proxy.value(forKey: "bundleURL") as? URL
            let icon = url.map { workspace.icon(forFile: $0.path) } ?? NSWorkspace.shared.icon(for: .application)
            return AppItem(id: id, name: name, url: url, icon: icon)
        }
    }

    private func scanFileSystem() -> [AppItem] {
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
                let name = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
                    ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
                    ?? appURL.deletingPathExtension().lastPathComponent
                let icon = workspace.icon(forFile: appURL.path)
                items.append(AppItem(id: id, name: name, url: appURL, icon: icon))
            }
        }
        return items
    }
}
