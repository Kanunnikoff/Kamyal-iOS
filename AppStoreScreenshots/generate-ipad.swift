import AppKit
import ImageIO
import UniformTypeIdentifiers

private enum Constants {
    static let canvasSize = NSSize(width: 2_752, height: 2_064)
    static let screenshotWidth: CGFloat = 1_940
    static let screenshotTop: CGFloat = 300
    static let screenshotLeft: CGFloat = 720
    static let screenshotCornerRadius: CGFloat = 76
    static let frameInset: CGFloat = 18
    static let brandIconSize: CGFloat = 104
    static let brandIconCornerRadius: CGFloat = 25
    static let outputDirectoryName = "13-inch"
}

private struct Slide {
    let sourceFileName: String
    let outputFileName: String
    let title: String
    let subtitle: String
    let glowColor: NSColor
    let glowCenter: NSPoint
}

private enum GenerationError: LocalizedError {
    case invalidArguments
    case imageLoadingFailed(URL)
    case pngEncodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidArguments:
            return "Ожидается путь к каталогу проекта первым параметром."
        case let .imageLoadingFailed(url):
            return "Не удалось открыть изображение: \(url.path)"
        case .pngEncodingFailed:
            return "Не удалось преобразовать итоговое изображение в PNG."
        }
    }
}

private func loadImage(at url: URL) throws -> NSImage {
    guard let image = NSImage(contentsOf: url) else {
        throw GenerationError.imageLoadingFailed(url)
    }

    return image
}

private func aspectFillRect(for imageSize: NSSize, in destination: NSRect) -> NSRect {
    let horizontalScale = destination.width / imageSize.width
    let verticalScale = destination.height / imageSize.height
    let scale = max(horizontalScale, verticalScale)
    let scaledSize = NSSize(
        width: imageSize.width * scale,
        height: imageSize.height * scale
    )

    return NSRect(
        x: destination.midX - scaledSize.width / 2,
        y: destination.midY - scaledSize.height / 2,
        width: scaledSize.width,
        height: scaledSize.height
    )
}

private func drawAspectFill(_ image: NSImage, in destination: NSRect) {
    let drawRect = aspectFillRect(for: image.size, in: destination)

    image.draw(
        in: drawRect,
        from: .zero,
        operation: .sourceOver,
        fraction: 1,
        respectFlipped: true,
        hints: [.interpolation: NSImageInterpolation.high]
    )
}

private func paragraphStyle(
    alignment: NSTextAlignment,
    lineSpacing: CGFloat
) -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    style.lineBreakMode = .byWordWrapping
    style.lineSpacing = lineSpacing

    return style
}

private func drawText(
    _ text: String,
    in rect: NSRect,
    font: NSFont,
    color: NSColor,
    alignment: NSTextAlignment = .left,
    lineSpacing: CGFloat = 0,
    kerning: CGFloat = 0
) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle(
            alignment: alignment,
            lineSpacing: lineSpacing
        ),
        .kern: kerning
    ]

    text.draw(
        with: rect,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes
    )
}

private func fittedFont(
    for text: String,
    in rect: NSRect,
    maximumSize: CGFloat,
    minimumSize: CGFloat,
    weight: NSFont.Weight,
    lineSpacing: CGFloat
) -> NSFont {
    var size = maximumSize

    while size >= minimumSize {
        let font = NSFont.systemFont(ofSize: size, weight: weight)
        let lines = text.components(separatedBy: "\n")
        let widestLine = lines
            .map { line in
                line.size(withAttributes: [.font: font]).width
            }
            .max() ?? 0
        let lineHeight = font.ascender - font.descender + font.leading
        let totalHeight = lineHeight * CGFloat(lines.count)
            + lineSpacing * CGFloat(max(lines.count - 1, 0))

        // Измеряем каждую заданную строку отдельно: обычное измерение абзаца
        // может разрешить перенос внутри длинного слова и пропустить дефект.
        if widestLine <= rect.width && totalHeight <= rect.height {
            return font
        }

        size -= 2
    }

    return .systemFont(ofSize: minimumSize, weight: weight)
}

private func drawGlow(center: NSPoint, color: NSColor) {
    let glowSize = NSSize(width: 1_600, height: 1_600)
    let glowRect = NSRect(
        x: center.x - glowSize.width / 2,
        y: center.y - glowSize.height / 2,
        width: glowSize.width,
        height: glowSize.height
    )
    let glowPath = NSBezierPath(ovalIn: glowRect)
    let glowGradient = NSGradient(
        starting: color.withAlphaComponent(0.32),
        ending: color.withAlphaComponent(0)
    )

    glowGradient?.draw(in: glowPath, relativeCenterPosition: .zero)
}

private func drawBrand(icon: NSImage) {
    let iconRect = NSRect(
        x: 86,
        y: 76,
        width: Constants.brandIconSize,
        height: Constants.brandIconSize
    )

    NSGraphicsContext.saveGraphicsState()
    let iconShadow = NSShadow()
    iconShadow.shadowColor = NSColor.black.withAlphaComponent(0.36)
    iconShadow.shadowBlurRadius = 26
    iconShadow.shadowOffset = NSSize(width: 0, height: 10)
    iconShadow.set()
    NSColor.white.setFill()
    NSBezierPath(
        roundedRect: iconRect,
        xRadius: Constants.brandIconCornerRadius,
        yRadius: Constants.brandIconCornerRadius
    ).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(
        roundedRect: iconRect,
        xRadius: Constants.brandIconCornerRadius,
        yRadius: Constants.brandIconCornerRadius
    ).addClip()
    drawAspectFill(icon, in: iconRect)
    NSGraphicsContext.restoreGraphicsState()

    let iconBorder = NSBezierPath(
        roundedRect: iconRect,
        xRadius: Constants.brandIconCornerRadius,
        yRadius: Constants.brandIconCornerRadius
    )
    iconBorder.lineWidth = 2
    NSColor.white.withAlphaComponent(0.72).setStroke()
    iconBorder.stroke()

    drawText(
        "Къамаьл",
        in: NSRect(x: 222, y: 78, width: 430, height: 58),
        font: .systemFont(ofSize: 48, weight: .bold),
        color: .white
    )
    drawText(
        "ИНГУШСКАЯ КЛАВИАТУРА",
        in: NSRect(x: 224, y: 138, width: 480, height: 36),
        font: .systemFont(ofSize: 25, weight: .semibold),
        color: NSColor(calibratedRed: 0.51, green: 0.85, blue: 1, alpha: 1),
        kerning: 2.5
    )
}

private func drawCopyPanel(for slide: Slide) {
    let panelRect = NSRect(x: 68, y: 270, width: 606, height: 1_510)

    // Полупрозрачная панель отделяет рекламный текст от сложного орнамента,
    // сохраняя при этом общий цвет и глубину фона предыдущей серии.
    NSGraphicsContext.saveGraphicsState()
    let panelShadow = NSShadow()
    panelShadow.shadowColor = NSColor.black.withAlphaComponent(0.32)
    panelShadow.shadowBlurRadius = 42
    panelShadow.shadowOffset = NSSize(width: 0, height: 18)
    panelShadow.set()
    NSColor(calibratedWhite: 0.01, alpha: 0.22).setFill()
    NSBezierPath(roundedRect: panelRect, xRadius: 54, yRadius: 54).fill()
    NSGraphicsContext.restoreGraphicsState()

    let panelBorder = NSBezierPath(roundedRect: panelRect, xRadius: 54, yRadius: 54)
    panelBorder.lineWidth = 2
    NSColor.white.withAlphaComponent(0.13).setStroke()
    panelBorder.stroke()

    let titleRect = NSRect(x: 110, y: 420, width: 516, height: 590)
    let titleLineSpacing: CGFloat = -4
    let titleFont = fittedFont(
        for: slide.title,
        in: titleRect,
        maximumSize: 74,
        minimumSize: 62,
        weight: .heavy,
        lineSpacing: titleLineSpacing
    )

    drawText(
        slide.title,
        in: titleRect,
        font: titleFont,
        color: .white,
        lineSpacing: titleLineSpacing,
        kerning: -1.4
    )

    NSColor(calibratedRed: 0.22, green: 0.89, blue: 1, alpha: 1).setFill()
    NSBezierPath(
        roundedRect: NSRect(x: 110, y: 1_042, width: 164, height: 10),
        xRadius: 5,
        yRadius: 5
    ).fill()

    drawText(
        slide.subtitle,
        in: NSRect(x: 110, y: 1_104, width: 510, height: 270),
        font: .systemFont(ofSize: 39, weight: .medium),
        color: NSColor(calibratedRed: 0.77, green: 0.89, blue: 1, alpha: 1),
        lineSpacing: 8
    )
}

private func drawScreenshot(_ screenshot: NSImage) {
    let screenshotHeight = Constants.screenshotWidth * screenshot.size.height / screenshot.size.width
    let screenshotRect = NSRect(
        x: Constants.screenshotLeft,
        y: Constants.screenshotTop,
        width: Constants.screenshotWidth,
        height: screenshotHeight
    )
    let frameRect = screenshotRect.insetBy(
        dx: -Constants.frameInset,
        dy: -Constants.frameInset
    )

    NSGraphicsContext.saveGraphicsState()
    let screenshotShadow = NSShadow()
    screenshotShadow.shadowColor = NSColor.black.withAlphaComponent(0.58)
    screenshotShadow.shadowBlurRadius = 72
    screenshotShadow.shadowOffset = NSSize(width: 0, height: 30)
    screenshotShadow.set()
    NSColor(calibratedWhite: 0.03, alpha: 0.96).setFill()
    NSBezierPath(
        roundedRect: frameRect,
        xRadius: Constants.screenshotCornerRadius + Constants.frameInset,
        yRadius: Constants.screenshotCornerRadius + Constants.frameInset
    ).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.95).setFill()
    NSBezierPath(
        roundedRect: frameRect,
        xRadius: Constants.screenshotCornerRadius + Constants.frameInset,
        yRadius: Constants.screenshotCornerRadius + Constants.frameInset
    ).fill()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(
        roundedRect: screenshotRect,
        xRadius: Constants.screenshotCornerRadius,
        yRadius: Constants.screenshotCornerRadius
    ).addClip()
    drawAspectFill(screenshot, in: screenshotRect)
    NSGraphicsContext.restoreGraphicsState()

    let innerBorder = NSBezierPath(
        roundedRect: screenshotRect,
        xRadius: Constants.screenshotCornerRadius,
        yRadius: Constants.screenshotCornerRadius
    )
    innerBorder.lineWidth = 3
    NSColor.white.withAlphaComponent(0.56).setStroke()
    innerBorder.stroke()
}

private func renderSlide(
    slide: Slide,
    background: NSImage,
    icon: NSImage,
    screenshot: NSImage,
    outputURL: URL
) throws {
    let renderedImage = NSImage(size: Constants.canvasSize, flipped: true) { canvas in
        drawAspectFill(background, in: canvas)

        let contrastGradient = NSGradient(colors: [
            NSColor(calibratedWhite: 0.01, alpha: 0.40),
            NSColor(calibratedWhite: 0.01, alpha: 0.04)
        ])
        contrastGradient?.draw(in: canvas, angle: 0)

        drawGlow(center: slide.glowCenter, color: slide.glowColor)
        drawBrand(icon: icon)
        drawCopyPanel(for: slide)
        drawScreenshot(screenshot)

        return true
    }

    guard
        let tiffData = renderedImage.tiffRepresentation,
        let sourceBitmap = NSBitmapImageRep(data: tiffData),
        let sourceCGImage = sourceBitmap.cgImage
    else {
        throw GenerationError.pngEncodingFailed
    }

    let pixelWidth = Int(Constants.canvasSize.width)
    let pixelHeight = Int(Constants.canvasSize.height)
    let bytesPerPixel = 4
    let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
        | CGImageAlphaInfo.noneSkipLast.rawValue

    guard let bitmapContext = CGContext(
        data: nil,
        width: pixelWidth,
        height: pixelHeight,
        bitsPerComponent: 8,
        bytesPerRow: pixelWidth * bytesPerPixel,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: bitmapInfo
    ) else {
        throw GenerationError.pngEncodingFailed
    }

    // Результат принудительно записывается как обычный RGB без прозрачности,
    // чтобы файл соответствовал требованиям загрузки снимков в App Store.
    bitmapContext.draw(
        sourceCGImage,
        in: CGRect(origin: .zero, size: Constants.canvasSize)
    )

    guard
        let cgImage = bitmapContext.makeImage(),
        let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        )
    else {
        throw GenerationError.pngEncodingFailed
    }

    CGImageDestinationAddImage(destination, cgImage, nil)

    guard CGImageDestinationFinalize(destination) else {
        throw GenerationError.pngEncodingFailed
    }
}

private func run() throws {
    guard CommandLine.arguments.count >= 2 else {
        throw GenerationError.invalidArguments
    }

    let projectURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    let assetsURL = projectURL.appendingPathComponent("AppStoreScreenshots", isDirectory: true)
    let sourceURL = assetsURL.appendingPathComponent("Source", isDirectory: true)
    let iPadSourceURL = sourceURL.appendingPathComponent("iPad", isDirectory: true)
    let outputURL = assetsURL.appendingPathComponent(Constants.outputDirectoryName, isDirectory: true)
    let background = try loadImage(
        at: sourceURL.appendingPathComponent("ornamental-background-ipad.png")
    )
    let icon = try loadImage(
        at: projectURL.appendingPathComponent(
            "Kamyal/Assets.xcassets/AppIcon.appiconset/kamyal_app_icon.png"
        )
    )

    let slides = [
        Slide(
            sourceFileName: "source-01-cyrillic.png",
            outputFileName: "01-write-in-ingush.png",
            title: "Пишите\nпо‑ингушски.\nБез\nкомпромиссов",
            subtitle: "Родная клавиатура — в любом приложении",
            glowColor: NSColor(calibratedRed: 0.04, green: 0.95, blue: 0.92, alpha: 1),
            glowCenter: NSPoint(x: 2_250, y: 1_280)
        ),
        Slide(
            sourceFileName: "source-02-latin.png",
            outputFileName: "02-two-alphabets.png",
            title: "Два\nалфавита.\nОдна\nклавиатура",
            subtitle: "Кириллица и латиница — переключайтесь мгновенно",
            glowColor: NSColor(calibratedRed: 0.19, green: 0.55, blue: 1, alpha: 1),
            glowCenter: NSPoint(x: 2_130, y: 850)
        ),
        Slide(
            sourceFileName: "source-03-alphabet.png",
            outputFileName: "03-alphabet-at-hand.png",
            title: "Весь\nингушский\nалфавит\nпод рукой",
            subtitle: "Все буквы и сочетания — всегда перед глазами",
            glowColor: NSColor(calibratedRed: 0.98, green: 0.68, blue: 0.23, alpha: 1),
            glowCenter: NSPoint(x: 2_210, y: 830)
        )
    ]

    for slide in slides {
        let screenshot = try loadImage(
            at: iPadSourceURL.appendingPathComponent(slide.sourceFileName)
        )
        try renderSlide(
            slide: slide,
            background: background,
            icon: icon,
            screenshot: screenshot,
            outputURL: outputURL.appendingPathComponent(slide.outputFileName)
        )
    }
}

do {
    try run()
} catch {
    FileHandle.standardError.write(
        Data("Ошибка: \(error.localizedDescription)\n".utf8)
    )
    exit(EXIT_FAILURE)
}
