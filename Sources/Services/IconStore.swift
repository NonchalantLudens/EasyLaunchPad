import AppKit
import Foundation

/// 异步加载并缓存应用图标（后台解码、预缩放到 2x 显示尺寸）。
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
        let resized = Self.resize(image, to: 192)
        cache[key] = resized
        return resized
    }

    private static let placeholderIcon = NSWorkspace.shared.icon(for: .application)

    private static func resize(_ image: NSImage, to points: CGFloat) -> NSImage {
        let pixels = points * 2
        let target = NSSize(width: pixels, height: pixels)
        let result = NSImage(size: target)
        result.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(
            in: NSRect(origin: .zero, size: target),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )
        result.unlockFocus()
        return result
    }
}
