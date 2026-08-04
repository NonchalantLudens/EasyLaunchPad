import AppKit

// Finder 窗口 640x400（点），背景图 1:1 像素。
// 实测：Finder 的 item position 即图标中心。
// 图标中心：LaunchPad.app (140,220)，Applications (420,220)；箭头在 y=220。
let W: Int = 640
let H: Int = 400

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: W,
    pixelsHigh: H,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .calibratedRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else { fatalError("failed to create bitmap") }
rep.size = NSSize(width: W, height: H)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current?.imageInterpolation = .high

// 浅色背景（保证 Finder 默认黑色图标标签可读）
let bgRect = NSRect(x: 0, y: 0, width: W, height: H)
NSGradient(colors: [
    NSColor(calibratedRed: 0.97, green: 0.97, blue: 0.98, alpha: 1),
    NSColor(calibratedRed: 0.88, green: 0.89, blue: 0.92, alpha: 1),
])?.draw(in: bgRect, angle: -90)

// 文字置于窗口中部偏下（图标回到顶部默认布局后，y=60 过于靠下）
func drawText(_ string: String, center: NSPoint, fontSize: CGFloat, color: NSColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .medium),
        .foregroundColor: color,
    ]
    let attr = NSAttributedString(string: string, attributes: attrs)
    let s = attr.size()
    attr.draw(at: NSPoint(x: center.x - s.width / 2, y: center.y - s.height / 2))
}
drawText("将 LaunchPad 拖入 Applications 文件夹以安装",
         center: NSPoint(x: 320, y: 180), fontSize: 15,
         color: NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.34, alpha: 1))

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render background")
}
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("background written to \(CommandLine.arguments[1])")
