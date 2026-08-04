import AppKit

// Finder 窗口 640x400（点），背景图按 1:1 像素生成，坐标与 Finder 图标位置一致。
// 用显式 NSBitmapImageRep 作为绘制目标，避免 Retina 屏下 lockFocus 按 2x 渲染。
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

// 深色渐变背景（与应用图标同色系）
let bgRect = NSRect(x: 0, y: 0, width: W, height: H)
NSGradient(colors: [
    NSColor(calibratedRed: 0.07, green: 0.12, blue: 0.28, alpha: 1),
    NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.10, alpha: 1),
])?.draw(in: bgRect, angle: -90)

// 顶部装饰：app.svg 风格红色网格图标
func drawGridIcon(center: NSPoint, side: CGFloat) {
    let cell = side * 0.34
    let gap = side * 0.06
    let startX = center.x - (cell + gap / 2)
    NSColor(calibratedRed: 0.71, green: 0.10, blue: 0.00, alpha: 1).setFill()
    for row in 0..<2 {
        for col in 0..<2 {
            let r = NSRect(
                x: startX + CGFloat(col) * (cell + gap),
                y: center.y - side / 2 + CGFloat(row) * (cell + gap),
                width: cell,
                height: cell
            )
            NSBezierPath(roundedRect: r, xRadius: cell * 0.18, yRadius: cell * 0.18).fill()
        }
    }
}

func drawText(_ string: String, center: NSPoint, fontSize: CGFloat, weight: NSFont.Weight, color: NSColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: weight),
        .foregroundColor: color,
    ]
    let attr = NSAttributedString(string: string, attributes: attrs)
    let s = attr.size()
    attr.draw(at: NSPoint(x: center.x - s.width / 2, y: center.y - s.height / 2))
}

// 顶部：图标 + 标题 + 副标题
drawGridIcon(center: NSPoint(x: 320, y: 330), side: 56)
drawText("LaunchPad", center: NSPoint(x: 320, y: 288), fontSize: 34, weight: .semibold, color: .white)
drawText("将 LaunchPad 拖入 Applications 文件夹以安装",
         center: NSPoint(x: 320, y: 256), fontSize: 16, weight: .regular,
         color: NSColor.white.withAlphaComponent(0.75))

// 放置区（与 Finder 图标位置对应：App 中心 (184,104)，Applications 中心 (464,104)）
for center in [NSPoint(x: 184, y: 104), NSPoint(x: 464, y: 104)] {
    let circle = NSBezierPath(ovalIn: NSRect(x: center.x - 70, y: center.y - 70, width: 140, height: 140))
    NSColor.white.withAlphaComponent(0.22).setStroke()
    circle.lineWidth = 2
    circle.stroke()
}

// 引导箭头
let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 252, y: 104))
arrow.line(to: NSPoint(x: 400, y: 104))
arrow.setLineDash([10, 8], count: 2, phase: 0)
NSColor.white.withAlphaComponent(0.6).setStroke()
arrow.lineWidth = 3
arrow.stroke()

let head = NSBezierPath()
head.move(to: NSPoint(x: 400, y: 104))
head.line(to: NSPoint(x: 388, y: 95))
head.move(to: NSPoint(x: 400, y: 104))
head.line(to: NSPoint(x: 388, y: 113))
NSColor.white.withAlphaComponent(0.6).setStroke()
head.lineWidth = 3
head.stroke()

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render background")
}
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("background written to \(CommandLine.arguments[1])")
