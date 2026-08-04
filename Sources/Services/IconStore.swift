import AppKit
import Foundation

/// 异步加载并缓存应用图标（保留多分辨率表示，由系统按显示尺寸选择最佳 rep）。
actor IconStore {
    static let shared = IconStore()

    private var cache: [String: NSImage] = [:]

    func icon(for url: URL?) async -> NSImage {
        guard let url else { return Self.placeholderIcon }
        let key = url.path
        if let cached = cache[key] { return cached }
        let image = await Task.detached(priority: .userInitiated) {
            NSWorkspace.shared.icon(forFile: url.path)
        }.value
        cache[key] = image
        return image
    }

    /// 后台预热所有应用图标，首次呼出即时显示。
    func prewarm(urls: [URL]) async {
        for url in urls where cache[url.path] == nil {
            _ = await icon(for: url)
        }
    }

    private static let placeholderIcon = NSWorkspace.shared.icon(for: .application)
}
