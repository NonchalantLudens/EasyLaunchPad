import AppKit

// Finder 窗口 640x400（点），背景图 1:1 像素。
// 图标中心（依据 Finder 位置 {140,60}/{420,60} + 88pt 图标）：左 (184,104)，右 (464,104)。
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

// 简单深色渐变背景
let bgRect = NSRect(x: 0, y: 0, width: W, height: H)
NSGradient(colors: [
    NSColor(calibratedRed: 0.07, green: 0.12, blue: 0.28, alpha: 1),
    NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.10, alpha: 1),
])?.draw(in: bgRect, angle: -90)

// 两个图标之间的引导箭头（y=104 为图标垂直中心，横跨两图标间隙）
let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 240, y: 104))
arrow.line(to: NSPoint(x: 400, y: 104))
NSColor.white.withAlphaComponent(0.85).setStroke()
arrow.lineWidth = 5
arrow.lineCapStyle = .round
arrow.stroke()

let head = NSBezierPath()
head.move(to: NSPoint(x: 404, y: 104))
head.line(to: NSPoint(x: 384, y: 92))
head.move(to: NSPoint(x: 404, y: 104))
head.line(to: NSPoint(x: 384, y: 116))
NSColor.white.withAlphaComponent(0.85).setStroke()
head.lineWidth = 5
head.lineCapStyle = .round
head.lineJoinStyle = .round
head.stroke()

// 下方简单文字提醒
func drawText(_ string: String, center: NSPoint, fontSize: CGFloat, color: NSColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .regular),
        .foregroundColor: color,
    ]
    let attr = NSAttributedString(string: string, attributes: attrs)
    let s = attr.size()
    attr.draw(at: NSPoint(x: center.x - s.width / 2, y: center.y - s.height / 2))
}
drawText("将 LaunchPad 拖入 Applications 文件夹以安装",
         center: NSPoint(x: 320, y: 28), fontSize: 15,
         color: NSColor.white.withAlphaComponent(0.8))

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render background")
}
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("background written to \(CommandLine.arguments[1])")
