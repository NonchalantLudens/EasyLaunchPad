import Foundation

struct HiddenAppRecord: Codable, Equatable {
    let id: String
    let name: String
    let url: URL?
}

enum LaunchpadStore {
    private static let defaults = UserDefaults.standard

    private enum Key {
        static let hiddenApps = "hiddenApps"
        static let manualApps = "manualApps"
    }

    static func loadHiddenApps() -> [HiddenAppRecord] {
        guard let data = defaults.data(forKey: Key.hiddenApps),
              let records = try? JSONDecoder().decode([HiddenAppRecord].self, from: data)
        else { return [] }
        return records
    }

    static func saveHiddenApps(_ records: [HiddenAppRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: Key.hiddenApps)
        }
    }

    static func loadManualURLs() -> [URL] {
        defaults.stringArray(forKey: Key.manualApps)?.compactMap(URL.init(string:)) ?? []
    }

    static func saveManualURLs(_ urls: [URL]) {
        defaults.set(urls.map(\.absoluteString), forKey: Key.manualApps)
    }
}
