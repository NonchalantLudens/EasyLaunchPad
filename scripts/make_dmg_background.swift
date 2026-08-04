import AppKit

let W: CGFloat = 640
let H: CGFloat = 400
let scale: CGFloat = 2

let image = NSImage(size: NSSize(width: W * scale, height: H * scale))
image.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high

// 深色渐变背景（与应用图标同色系）
let bgRect = NSRect(x: 0, y: 0, width: W * scale, height: H * scale)
NSGradient(colors: [
    NSColor(calibratedRed: 0.07, green: 0.12, blue: 0.28, alpha: 1),
    NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.10, alpha: 1),
])?.draw(in: bgRect, angle: -90)

func pt(_ x: CGFloat, _ y: CGFloat) -> NSPoint { NSPoint(x: x * scale, y: y * scale) }
func rct(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
    NSRect(x: x * scale, y: y * scale, width: w * scale, height: h * scale)
}

// 顶部装饰：app.svg 风格红色网格图标
func drawGridIcon(center: NSPoint, side: CGFloat) {
    let cell = side * 0.34
    let gap = side * 0.06
    let startX = center.x - (cell + gap / 2)
    let color = NSColor(calibratedRed: 0.71, green: 0.10, blue: 0.00, alpha: 1)
    color.setFill()
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
        .font: NSFont.systemFont(ofSize: fontSize * scale, weight: weight),
        .foregroundColor: color,
    ]
    let attr = NSAttributedString(string: string, attributes: attrs)
    let s = attr.size()
    attr.draw(at: NSPoint(x: center.x - s.width / 2, y: center.y - s.height / 2))
}

// 顶部：图标 + 标题 + 副标题
drawGridIcon(center: pt(320, 330), side: 56)
drawText("LaunchPad", center: pt(320, 288), fontSize: 34, weight: .semibold, color: .white)
drawText("将 LaunchPad 拖入 Applications 文件夹以安装",
         center: pt(320, 256), fontSize: 16, weight: .regular,
         color: NSColor.white.withAlphaComponent(0.75))

// 放置区（与 Finder 图标位置对应：App 中心 (184,104)，Applications 中心 (464,104)）
for center in [pt(184, 104), pt(464, 104)] {
    let circle = NSBezierPath(ovalIn: NSRect(x: center.x - 70 * scale, y: center.y - 70 * scale, width: 140 * scale, height: 140 * scale))
    NSColor.white.withAlphaComponent(0.22).setStroke()
    circle.lineWidth = 2 * scale
    circle.stroke()
}

// 引导箭头
let arrow = NSBezierPath()
arrow.move(to: pt(252, 104))
arrow.line(to: pt(400, 104))
arrow.setLineDash([10 * scale, 8 * scale], count: 2, phase: 0)
NSColor.white.withAlphaComponent(0.6).setStroke()
arrow.lineWidth = 3 * scale
arrow.stroke()

let head = NSBezierPath()
head.move(to: pt(400, 104))
head.line(to: pt(388, 95))
head.move(to: pt(400, 104))
head.line(to: pt(388, 113))
NSColor.white.withAlphaComponent(0.6).setStroke()
head.lineWidth = 3 * scale
head.stroke()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:])
else { fatalError("failed to render background") }
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("background written to \(CommandLine.arguments[1])")
