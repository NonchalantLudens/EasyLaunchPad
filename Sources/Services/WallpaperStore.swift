import AppKit
import CoreImage

/// 加载当前桌面壁纸并做高斯模糊，用作 LaunchPad 背景（还原经典"模糊壁纸压暗"观感）。
final class WallpaperStore {
    static let shared = WallpaperStore()

    private var cache: [String: NSImage] = [:]
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    private let lock = NSLock()

    func load(for screen: NSScreen, completion: @escaping (NSImage?) -> Void) {
        let key = Self.key(for: screen)
        lock.lock()
        let cached = cache[key]
        lock.unlock()
        if let cached {
            completion(cached)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let image = self.build(for: screen)
            if let image {
                self.lock.lock()
                self.cache[key] = image
                self.lock.unlock()
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    func preloadMainScreen() {
        if let screen = NSScreen.main {
            load(for: screen) { _ in }
        }
    }

    private static func key(for screen: NSScreen) -> String {
        let url = NSWorkspace.shared.desktopImageURL(for: screen)?.path ?? "none"
        return "\(url)|\(screen.frame.width)x\(screen.frame.height)"
    }

    private func build(for screen: NSScreen) -> NSImage? {
        guard let url = NSWorkspace.shared.desktopImageURL(for: screen),
              let ci = CIImage(contentsOf: url, options: [.applyOrientationProperty: true])
        else { return nil }

        let maxWidth: CGFloat = 1280
        let scale = min(1, maxWidth / ci.extent.width)
        let scaled = ci.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let blurred = scaled
            .clampedToExtent()
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 12])
            .cropped(to: scaled.extent)

        guard let cg = ciContext.createCGImage(blurred, from: blurred.extent) else { return nil }
        return NSImage(
            cgImage: cg,
            size: NSSize(width: blurred.extent.width, height: blurred.extent.height)
        )
    }
}
