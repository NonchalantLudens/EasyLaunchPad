import Carbon.HIToolbox
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
        static let hotkeyKeyCode = "hotkeyKeyCode"
        static let hotkeyModifiers = "hotkeyModifiers"
        static let swipeEnabled = "gestureSwipeEnabled"
        static let pinchEnabled = "gesturePinchEnabled"
        static let autoStart = "autoStart"
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

    // MARK: - Settings

    static func loadHotkeyKeyCode() -> UInt32 {
        let value = defaults.integer(forKey: Key.hotkeyKeyCode)
        return value > 0 ? UInt32(value) : UInt32(kVK_F4)
    }

    static func saveHotkey(keyCode: UInt32, modifiers: UInt32) {
        defaults.set(Int(keyCode), forKey: Key.hotkeyKeyCode)
        defaults.set(Int(modifiers), forKey: Key.hotkeyModifiers)
    }

    static func loadHotkeyModifiers() -> UInt32 {
        UInt32(defaults.integer(forKey: Key.hotkeyModifiers))
    }

    static func loadSwipeEnabled() -> Bool {
        if defaults.object(forKey: Key.swipeEnabled) == nil { return true }
        return defaults.bool(forKey: Key.swipeEnabled)
    }

    static func saveSwipeEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Key.swipeEnabled)
    }

    static func loadPinchEnabled() -> Bool {
        if defaults.object(forKey: Key.pinchEnabled) == nil { return true }
        return defaults.bool(forKey: Key.pinchEnabled)
    }

    static func savePinchEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Key.pinchEnabled)
    }

    static func loadAutoStart() -> Bool {
        defaults.bool(forKey: Key.autoStart)
    }

    static func saveAutoStart(_ enabled: Bool) {
        defaults.set(enabled, forKey: Key.autoStart)
    }
}
