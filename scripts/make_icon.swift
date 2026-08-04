import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let bgPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: 224, yRadius: 224)
NSGradient(colors: [
    NSColor(calibratedRed: 0.16, green: 0.38, blue: 0.93, alpha: 1),
    NSColor(calibratedRed: 0.05, green: 0.10, blue: 0.32, alpha: 1),
])?.draw(in: bgPath, angle: -60)

let cell: CGFloat = 176
let gap: CGFloat = 30
let count: CGFloat = 4
let total = count * cell + (count - 1) * gap
let originX = (1024 - total) / 2
let originY = (1024 - total) / 2

let tile = NSColor.white
let tileAlpha: CGFloat = 0.92
for row in 0..<4 {
    for col in 0..<4 {
        let rect = NSRect(
            x: originX + CGFloat(col) * (cell + gap),
            y: originY + CGFloat(row) * (cell + gap),
            width: cell,
            height: cell
        )
        let tilePath = NSBezierPath(roundedRect: rect, xRadius: 46, yRadius: 46)
        tile.withAlphaComponent(tileAlpha).setFill()
        tilePath.fill()
    }
}

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:])
else {
    fatalError("failed to render icon")
}
try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("icon written to \(CommandLine.arguments[1])")
