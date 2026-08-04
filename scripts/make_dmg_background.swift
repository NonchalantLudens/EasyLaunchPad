import AppKit

// Finder 窗口 640x400（点），背景图 1:1 像素。
// 实测：Finder 的 item position 即图标中心。
// 图标中心：LaunchPad.app (140,120)，Applications (420,120)；箭头在 y=120。
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

// 两图标之间的引导箭头（深色，指向右侧 Applications）
let arrowColor = NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.34, alpha: 0.9)
let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 184, y: 120))
arrow.line(to: NSPoint(x: 386, y: 120))
arrowColor.setStroke()
arrow.lineWidth = 5
arrow.lineCapStyle = .round
arrow.stroke()

let head = NSBezierPath()
head.move(to: NSPoint(x: 390, y: 120))
head.line(to: NSPoint(x: 370, y: 108))
head.move(to: NSPoint(x: 390, y: 120))
head.line(to: NSPoint(x: 370, y: 132))
arrowColor.setStroke()
head.lineWidth = 5
head.lineCapStyle = .round
head.lineJoinStyle = .round
head.stroke()

// 下方简单文字提醒（图标标签之下，y=35）
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
         center: NSPoint(x: 320, y: 35), fontSize: 15,
         color: NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.34, alpha: 1))

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render background")
}
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("background written to \(CommandLine.arguments[1])")
