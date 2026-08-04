import AppKit
import Foundation

/// 异步加载并缓存应用图标（保留多分辨率表示，由系统按显示尺寸选择最佳 rep）。
actor IconStore {
    static let shared = IconStore()

    private let cache = NSCache<NSString, NSImage>()

    init() {
        cache.countLimit = 200
    }

    func icon(for url: URL?) async -> NSImage {
        guard let url else { return Self.placeholderIcon }
        let key = url.path as NSString
        if let cached = cache.object(forKey: key) { return cached }
        let image = await Task.detached(priority: .userInitiated) {
            NSWorkspace.shared.icon(forFile: url.path)
        }.value
        cache.setObject(image, forKey: key)
        return image
    }

    /// 后台预热所有应用图标，首次呼出即时显示。
    func prewarm(urls: [URL]) async {
        for url in urls {
            _ = await icon(for: url)
        }
    }

    private static let placeholderIcon = NSWorkspace.shared.icon(for: .application)
}
