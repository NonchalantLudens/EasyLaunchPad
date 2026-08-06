import AppKit

// 用法: make_dmg_background.swift <输出路径> [宽] [高]
// 背景图高度小于 Finder 内容区（窗口 480x300，标题栏 ~28pt → 内容 ~480x272，
// 背景取 480x250），任何锚定/缩放方式下文字都不会被裁剪。
let W: Int = CommandLine.arguments.count > 2 ? Int(CommandLine.arguments[2]) ?? 480 : 480
let H: Int = CommandLine.arguments.count > 3 ? Int(CommandLine.arguments[3]) ?? 250 : 250
// 文字位置按图像高度计算：距底部 20%（安全边距），永不贴近底边
let textY = Int(Double(H) * 0.20)

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

// 提示文字（居中，位置按图像高度计算）
func drawText(_ string: String, center: NSPoint, fontSize: CGFloat, color: NSColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .medium),
        .foregroundColor: color,
    ]
    let attr = NSAttributedString(string: string, attributes: attrs)
    let s = attr.size()
    attr.draw(at: NSPoint(x: center.x - s.width / 2, y: center.y - s.height / 2))
}
drawText("将 EasyLaunchPad 拖入 Applications 文件夹以安装",
         center: NSPoint(x: CGFloat(W) / 2, y: CGFloat(textY)), fontSize: 15,
         color: NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.34, alpha: 1))

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render background")
}
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("background \(W)x\(H) textY=\(textY) written")
