import AppKit
import ImageIO
import UniformTypeIdentifiers

/// Размеры и имена ресурсов для снимков iPhone с диагональю 6,5 дюйма.
private enum Constants {
    static let canvasSize = NSSize(width: 1_242, height: 2_688)
    static let screenshotWidth: CGFloat = 990
    static let screenshotTop: CGFloat = 652
    static let screenshotCornerRadius: CGFloat = 92
    static let frameInset: CGFloat = 14
    static let frameCornerRadius: CGFloat = screenshotCornerRadius + frameInset
    static let brandIconSize: CGFloat = 96
    static let brandIconCornerRadius: CGFloat = 23
    static let outputDirectoryName = "6.5-inch"
}

/// Описание текста, исходного снимка и свечения одного рекламного изображения.
private struct Slide {
    let sourceFileName: String
    let outputFileName: String
    let title: String
    let subtitle: String
    let glowColor: NSColor
    let glowCenter: NSPoint
}

/// Ошибки чтения ресурсов и записи готовых снимков.
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

/// Загружает изображение по указанному адресу.
///
/// - Parameter url: Адрес исходного файла.
/// - Returns: Загруженное изображение AppKit.
/// - Throws: `GenerationError.imageLoadingFailed`, если файл нельзя открыть.
private func loadImage(at url: URL) throws -> NSImage {
    guard let image = NSImage(contentsOf: url) else {
        throw GenerationError.imageLoadingFailed(url)
    }

    return image
}

/// Рассчитывает прямоугольник для заполнения области изображением без искажения пропорций.
///
/// - Parameters:
///   - imageSize: Исходный размер изображения.
///   - destination: Заполняемая область.
/// - Returns: Масштабированный прямоугольник с возможной обрезкой краёв.
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

/// Рисует изображение с заполнением всей области и обрезкой выступающих краёв.
///
/// - Parameters:
///   - image: Исходное изображение.
///   - destination: Заполняемая область.
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

/// Рисует оформленный многострочный текст.
///
/// - Parameters:
///   - text: Отображаемый текст.
///   - rect: Область размещения.
///   - font: Шрифт текста.
///   - color: Цвет текста.
///   - alignment: Выравнивание абзаца.
///   - lineSpacing: Дополнительное расстояние между строками.
///   - kerning: Межбуквенный интервал.
private func drawText(
    _ text: String,
    in rect: NSRect,
    font: NSFont,
    color: NSColor,
    alignment: NSTextAlignment = .center,
    lineSpacing: CGFloat = 0,
    kerning: CGFloat = 0
) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    paragraphStyle.lineBreakMode = .byWordWrapping
    paragraphStyle.lineSpacing = lineSpacing

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle,
        .kern: kerning
    ]

    text.draw(
        with: rect,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes
    )
}

/// Рисует радиальное цветное свечение на фоне.
///
/// - Parameters:
///   - center: Центр свечения.
///   - color: Основной цвет градиента.
private func drawGlow(center: NSPoint, color: NSColor) {
    let glowSize = NSSize(width: 1_000, height: 1_000)
    let glowRect = NSRect(
        x: center.x - glowSize.width / 2,
        y: center.y - glowSize.height / 2,
        width: glowSize.width,
        height: glowSize.height
    )
    let glowPath = NSBezierPath(ovalIn: glowRect)
    let glowGradient = NSGradient(
        starting: color.withAlphaComponent(0.38),
        ending: color.withAlphaComponent(0)
    )

    glowGradient?.draw(in: glowPath, relativeCenterPosition: .zero)
}

/// Рисует значок и название приложения в верхней части снимка.
///
/// - Parameter icon: Значок приложения.
private func drawBrand(icon: NSImage) {
    let iconRect = NSRect(
        x: 76,
        y: 68,
        width: Constants.brandIconSize,
        height: Constants.brandIconSize
    )

    // Иконка обрезается тем же скруглением, которое используется в App Store,
    // чтобы исходное квадратное изображение не выбивалось из общего макета.
    NSGraphicsContext.saveGraphicsState()
    let iconShadow = NSShadow()
    iconShadow.shadowColor = NSColor.black.withAlphaComponent(0.34)
    iconShadow.shadowBlurRadius = 24
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

    NSColor.white.withAlphaComponent(0.72).setStroke()
    let iconBorder = NSBezierPath(
        roundedRect: iconRect,
        xRadius: Constants.brandIconCornerRadius,
        yRadius: Constants.brandIconCornerRadius
    )
    iconBorder.lineWidth = 2
    iconBorder.stroke()

    drawText(
        "Къамаьл",
        in: NSRect(x: 198, y: 72, width: 420, height: 52),
        font: .systemFont(ofSize: 43, weight: .bold),
        color: .white,
        alignment: .left
    )
    drawText(
        "ИНГУШСКАЯ КЛАВИАТУРА",
        in: NSRect(x: 200, y: 126, width: 500, height: 34),
        font: .systemFont(ofSize: 23, weight: .semibold),
        color: NSColor(calibratedRed: 0.51, green: 0.85, blue: 1, alpha: 1),
        alignment: .left,
        kerning: 2.4
    )
}

/// Рисует заголовок, акцентную линию и подзаголовок слайда.
///
/// - Parameter slide: Описание текстового содержимого слайда.
private func drawHeadline(for slide: Slide) {
    drawText(
        slide.title,
        in: NSRect(x: 72, y: 220, width: 1_098, height: 246),
        font: .systemFont(ofSize: 100, weight: .heavy),
        color: .white,
        lineSpacing: -7,
        kerning: -1.8
    )

    let accentLine = NSBezierPath(
        roundedRect: NSRect(x: 531, y: 478, width: 180, height: 9),
        xRadius: 4.5,
        yRadius: 4.5
    )
    NSColor(calibratedRed: 0.22, green: 0.89, blue: 1, alpha: 1).setFill()
    accentLine.fill()

    drawText(
        slide.subtitle,
        in: NSRect(x: 92, y: 512, width: 1_058, height: 64),
        font: .systemFont(ofSize: 42, weight: .medium),
        color: NSColor(calibratedRed: 0.77, green: 0.89, blue: 1, alpha: 1),
        lineSpacing: 2
    )
}

/// Рисует исходный снимок приложения внутри декоративной рамки устройства.
///
/// - Parameter screenshot: Снимок интерфейса приложения.
private func drawScreenshot(_ screenshot: NSImage) {
    let screenshotHeight = Constants.screenshotWidth * screenshot.size.height / screenshot.size.width
    let screenshotRect = NSRect(
        x: (Constants.canvasSize.width - Constants.screenshotWidth) / 2,
        y: Constants.screenshotTop,
        width: Constants.screenshotWidth,
        height: screenshotHeight
    )
    let frameRect = screenshotRect.insetBy(
        dx: -Constants.frameInset,
        dy: -Constants.frameInset
    )

    // Рамка продолжается за нижний край макета намеренно: так экран выглядит
    // крупнее, а важные элементы клавиатуры сохраняют читаемый размер.
    NSGraphicsContext.saveGraphicsState()
    let screenshotShadow = NSShadow()
    screenshotShadow.shadowColor = NSColor.black.withAlphaComponent(0.55)
    screenshotShadow.shadowBlurRadius = 72
    screenshotShadow.shadowOffset = NSSize(width: 0, height: 28)
    screenshotShadow.set()
    NSColor(calibratedWhite: 0.03, alpha: 0.95).setFill()
    NSBezierPath(
        roundedRect: frameRect,
        xRadius: Constants.frameCornerRadius,
        yRadius: Constants.frameCornerRadius
    ).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.94).setFill()
    NSBezierPath(
        roundedRect: frameRect,
        xRadius: Constants.frameCornerRadius,
        yRadius: Constants.frameCornerRadius
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
    NSColor.white.withAlphaComponent(0.55).setStroke()
    innerBorder.stroke()
}

/// Собирает рекламный слайд и записывает его как непрозрачный PNG.
///
/// - Parameters:
///   - slide: Описание текущего слайда.
///   - background: Фоновое изображение.
///   - icon: Значок приложения.
///   - screenshot: Снимок интерфейса.
///   - outputURL: Адрес итогового PNG.
/// - Throws: `GenerationError.pngEncodingFailed`, если изображение нельзя растрировать или записать.
private func renderSlide(
    slide: Slide,
    background: NSImage,
    icon: NSImage,
    screenshot: NSImage,
    outputURL: URL
) throws {
    let renderedImage = NSImage(size: Constants.canvasSize, flipped: true) { canvas in
        drawAspectFill(background, in: canvas)

        // Полупрозрачный слой выравнивает контраст между тремя исходными
        // экранами и гарантирует одинаковую читаемость белых заголовков.
        let contrastGradient = NSGradient(colors: [
            NSColor(calibratedWhite: 0.01, alpha: 0.34),
            NSColor(calibratedWhite: 0.01, alpha: 0.04)
        ])
        contrastGradient?.draw(in: canvas, angle: -90)

        drawGlow(center: slide.glowCenter, color: slide.glowColor)
        drawBrand(icon: icon)
        drawHeadline(for: slide)
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

    // App Store не нуждается в прозрачности скриншотов. Сначала полностью
    // растрируем ленивое NSImage, а затем переносим его в RGB-контекст без
    // альфа-канала. Это исключает частичную отрисовку больших исходных PNG.
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

/// Загружает общие ресурсы и создаёт всю серию снимков iPhone.
///
/// - Throws: Ошибку аргументов, чтения исходных изображений или записи PNG.
private func run() throws {
    guard CommandLine.arguments.count >= 2 else {
        throw GenerationError.invalidArguments
    }

    let projectURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    let assetsURL = projectURL.appendingPathComponent("AppStoreScreenshots", isDirectory: true)
    let sourceURL = assetsURL.appendingPathComponent("Source", isDirectory: true)
    let outputURL = assetsURL.appendingPathComponent(Constants.outputDirectoryName, isDirectory: true)
    let background = try loadImage(
        at: sourceURL.appendingPathComponent("ornamental-background.png")
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
            title: "Пишите по‑ингушски.\nБез компромиссов",
            subtitle: "Родная клавиатура — в любом приложении",
            glowColor: NSColor(calibratedRed: 0.04, green: 0.95, blue: 0.92, alpha: 1),
            glowCenter: NSPoint(x: 980, y: 1_170)
        ),
        Slide(
            sourceFileName: "source-02-latin.png",
            outputFileName: "02-two-alphabets.png",
            title: "Два алфавита.\nОдна клавиатура",
            subtitle: "Кириллица и латиница — переключайтесь мгновенно",
            glowColor: NSColor(calibratedRed: 0.19, green: 0.55, blue: 1, alpha: 1),
            glowCenter: NSPoint(x: 260, y: 1_100)
        ),
        Slide(
            sourceFileName: "source-03-alphabet.png",
            outputFileName: "03-alphabet-at-hand.png",
            title: "Весь ингушский\nалфавит под рукой",
            subtitle: "Все буквы и сочетания — всегда перед глазами",
            glowColor: NSColor(calibratedRed: 0.98, green: 0.68, blue: 0.23, alpha: 1),
            glowCenter: NSPoint(x: 1_020, y: 1_030)
        )
    ]

    for slide in slides {
        let screenshot = try loadImage(
            at: sourceURL.appendingPathComponent(slide.sourceFileName)
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
