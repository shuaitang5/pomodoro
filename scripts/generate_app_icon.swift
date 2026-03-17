import AppKit
import Foundation

let arguments = CommandLine.arguments

guard arguments.count == 2 else {
    FileHandle.standardError.write(Data("Usage: generate_app_icon.swift <iconset-dir>\n".utf8))
    exit(1)
}

let outputDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
let fileManager = FileManager.default

try fileManager.createDirectory(
    at: outputDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

let sizes = [16, 32, 128, 256, 512]

for size in sizes {
    try writeIcon(pointSize: size, scale: 1, to: outputDirectory)
    try writeIcon(pointSize: size, scale: 2, to: outputDirectory)
}

func writeIcon(pointSize: Int, scale: Int, to directory: URL) throws {
    let pixelSize = pointSize * scale

    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "PomodoroTimerIcon", code: 1)
    }

    bitmap.size = NSSize(width: pointSize, height: pointSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    guard let context = NSGraphicsContext.current?.cgContext else {
        throw NSError(domain: "PomodoroTimerIcon", code: 2)
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let canvas = CGRect(x: 0, y: 0, width: CGFloat(pointSize), height: CGFloat(pointSize))
    drawBackground(in: canvas)
    drawTomato(in: canvas, context: context)

    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "PomodoroTimerIcon", code: 3)
    }

    let name = scale == 1 ? "icon_\(pointSize)x\(pointSize).png" : "icon_\(pointSize)x\(pointSize)@2x.png"
    try data.write(to: directory.appendingPathComponent(name))
}

func drawBackground(in rect: CGRect) {
    let inset = rect.width * 0.07
    let backgroundRect = rect.insetBy(dx: inset, dy: inset)
    let radius = rect.width * 0.22

    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedWhite: 0.20, alpha: 0.16)
    shadow.shadowBlurRadius = rect.width * 0.045
    shadow.shadowOffset = NSSize(width: 0, height: -(rect.width * 0.018))
    shadow.set()

    let path = NSBezierPath(roundedRect: backgroundRect, xRadius: radius, yRadius: radius)
    NSColor(calibratedRed: 0.99, green: 0.96, blue: 0.90, alpha: 1.0).setFill()
    path.fill()

    NSColor(calibratedRed: 0.90, green: 0.84, blue: 0.74, alpha: 1.0).setStroke()
    path.lineWidth = rect.width * 0.012
    path.stroke()
}

func drawTomato(in rect: CGRect, context: CGContext) {
    let tomatoRect = CGRect(
        x: rect.width * 0.20,
        y: rect.height * 0.18,
        width: rect.width * 0.60,
        height: rect.height * 0.54
    )

    let tomatoPath = CGPath(ellipseIn: tomatoRect, transform: nil)
    context.saveGState()
    context.addPath(tomatoPath)
    context.clip()

    let colors = [
        NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.34, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.79, green: 0.13, blue: 0.11, alpha: 1.0).cgColor
    ] as CFArray

    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors,
        locations: [0.0, 1.0]
    )!

    context.drawRadialGradient(
        gradient,
        startCenter: CGPoint(x: tomatoRect.minX + tomatoRect.width * 0.28, y: tomatoRect.maxY - tomatoRect.height * 0.15),
        startRadius: 0,
        endCenter: CGPoint(x: tomatoRect.midX, y: tomatoRect.midY),
        endRadius: tomatoRect.width * 0.6,
        options: []
    )
    context.restoreGState()

    context.setStrokeColor(NSColor(calibratedRed: 0.60, green: 0.07, blue: 0.06, alpha: 0.28).cgColor)
    context.setLineWidth(rect.width * 0.01)
    context.addPath(tomatoPath)
    context.strokePath()

    let highlight = CGRect(
        x: tomatoRect.minX + tomatoRect.width * 0.12,
        y: tomatoRect.minY + tomatoRect.height * 0.56,
        width: tomatoRect.width * 0.22,
        height: tomatoRect.height * 0.14
    )

    context.setFillColor(NSColor.white.withAlphaComponent(0.22).cgColor)
    context.fillEllipse(in: highlight)

    drawLeaves(around: CGPoint(x: rect.midX, y: tomatoRect.maxY + rect.height * 0.02), size: rect.width, context: context)

    context.saveGState()
    context.translateBy(x: rect.midX + rect.width * 0.02, y: tomatoRect.maxY + rect.height * 0.04)
    context.rotate(by: .pi / 7)
    let stemRect = CGRect(x: -rect.width * 0.02, y: 0, width: rect.width * 0.04, height: rect.height * 0.15)
    let stemPath = CGPath(roundedRect: stemRect, cornerWidth: rect.width * 0.02, cornerHeight: rect.width * 0.02, transform: nil)
    context.setFillColor(NSColor(calibratedRed: 0.34, green: 0.50, blue: 0.19, alpha: 1.0).cgColor)
    context.addPath(stemPath)
    context.fillPath()
    context.restoreGState()
}

func drawLeaves(around center: CGPoint, size: CGFloat, context: CGContext) {
    let leafAngles: [CGFloat] = [-0.9, -0.35, 0.15, 0.7]

    for angle in leafAngles {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: angle)

        let leafRect = CGRect(
            x: -size * 0.11,
            y: -size * 0.018,
            width: size * 0.22,
            height: size * 0.07
        )

        let leafPath = CGMutablePath()
        leafPath.move(to: CGPoint(x: leafRect.minX, y: leafRect.midY))
        leafPath.addQuadCurve(
            to: CGPoint(x: leafRect.maxX, y: leafRect.midY),
            control: CGPoint(x: leafRect.midX, y: leafRect.maxY + size * 0.03)
        )
        leafPath.addQuadCurve(
            to: CGPoint(x: leafRect.minX, y: leafRect.midY),
            control: CGPoint(x: leafRect.midX, y: leafRect.minY - size * 0.03)
        )

        context.setFillColor(NSColor(calibratedRed: 0.21, green: 0.57, blue: 0.21, alpha: 1.0).cgColor)
        context.addPath(leafPath)
        context.fillPath()
        context.restoreGState()
    }
}
