//
//  MyActionActionHandler.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit
import UIKit
import SwiftUI

/// Дополняет стандартную обработку KeyboardKit звуком, регистром и действиями с изображениями.
class MyKeyboardActionHandler: StandardKeyboardActionHandler {
    
    @AppStorage(KeyboardSettingsKey.isAudioFeedback, store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardAudioFeedback: Bool = false

    var isAutocapitalizationEnabled: Bool = true
    
    // MARK: - Overrides

    /// Разрешает обратную связь KeyboardKit с учётом настройки звука клавиш.
    ///
    /// - Parameters:
    ///   - gesture: Жест над клавишей.
    ///   - action: Действие клавиши.
    /// - Returns: `true`, если KeyboardKit следует воспроизвести обратную связь.
    override func shouldTriggerFeedback(for gesture: Keyboard.Gesture, on action: KeyboardAction) -> Bool {
        if isKeyboardAudioFeedback {
            return super.shouldTriggerFeedback(for: gesture, on: action)
        } else {
            return false
        }
    }

    /// Подменяет действия долгого нажатия и отпускания для клавиш-изображений.
    ///
    /// - Parameters:
    ///   - gesture: Распознанный жест.
    ///   - action: Действие клавиши.
    /// - Returns: Пользовательское либо стандартное действие для жеста.
    override func action(for gesture: Keyboard.Gesture, on action: KeyboardAction) -> KeyboardAction.GestureAction? {
        let standard = super.action(for: gesture, on: action)
        switch gesture {
            case .longPress: return longPressAction(for: action) ?? standard
            case .release: return releaseAction(for: action) ?? standard
            default: return standard
        }
    }

    /// Выбирает регистр после действия с учётом ручного Shift и пользовательской настройки.
    ///
    /// - Parameters:
    ///   - gesture: Завершившийся жест.
    ///   - action: Выполненное действие клавиши.
    /// - Returns: Регистр следующего состояния клавиатуры.
    override func preferredKeyboardCase(
        after gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> Keyboard.KeyboardCase {
        if action.isShiftAction {
            // Отключение автоматических заглавных букв не должно запрещать ручной
            // выбор регистра. К моменту этого вызова KeyboardKit уже переключил
            // состояние Shift, поэтому сохраняем результат стандартной обработки.
            return super.preferredKeyboardCase(after: gesture, on: action)
        }

        if keyboardContext.keyboardCase == .capsLocked {
            // Двойное нажатие на Shift явно включает постоянный верхний регистр.
            // Не позволяем автоматическому пересчёту отключить его после символа,
            // пробела или удаления: выйти из этого состояния можно только через Shift.
            return .capsLocked
        }

        // KeyboardKit пересчитывает регистр после пробела, удаления и ввода знаков.
        // При отключённой настройке не даём этим переходам снова включить Shift.
        guard isAutocapitalizationEnabled else {
            return .lowercased
        }

        return super.preferredKeyboardCase(after: gesture, on: action)
    }

    /// Сохраняет выбранный тип раскладки после ввода ингушского апострофа.
    ///
    /// - Parameters:
    ///   - gesture: Завершившийся жест.
    ///   - action: Выполненное действие клавиши.
    /// - Returns: Тип раскладки для следующего состояния.
    override func preferredKeyboardType(
        after gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> Keyboard.KeyboardType {
        if gesture == .release,
           case .character(let character) = action,
           KeyboardCharacters.apostrophes.contains(character) {
            // KeyboardKit считает апостроф знаком, после которого цифровая или
            // символьная раскладка должна автоматически смениться на буквенную.
            // Для ингушского ввода апостроф может быть частью набираемой
            // последовательности, поэтому оставляем выбранную раскладку без изменений.
            return keyboardContext.keyboardType
        }

        return super.preferredKeyboardType(after: gesture, on: action)
    }
    
    // MARK: - Custom actions

    /// Создаёт действие сохранения изображения для долгого нажатия.
    ///
    /// - Parameter action: Действие нажатой клавиши.
    /// - Returns: Замыкание сохранения либо `nil` для обычной клавиши.
    func longPressAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        switch action {
            case .image(_, _, let imageName): return { [weak self] _ in self?.saveImage(named: imageName) }
            default: return nil
        }
    }

    /// Создаёт действие копирования изображения при отпускании клавиши.
    ///
    /// - Parameter action: Действие отпущенной клавиши.
    /// - Returns: Замыкание копирования либо `nil` для обычной клавиши.
    func releaseAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        switch action {
            case .image(_, _, let imageName): return { [weak self] _ in self?.copyImage(named: imageName) }
            default: return nil
        }
    }
    

    // MARK: - Functions

    /// Обрабатывает текстовое уведомление внутри расширения клавиатуры.
    ///
    /// Метод намеренно ничего не делает: расширение не может показывать обычный
    /// `UIAlertController`. Подкласс может предоставить допустимый способ уведомления.
    ///
    /// - Parameter message: Текст уведомления.
    func alert(_ message: String) {}

    /// Копирует изображение в буфер обмена при наличии полного доступа.
    ///
    /// - Parameter image: Изображение для копирования.
    func copyImage(_ image: UIImage) {
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to copy images.") }
        guard image.copyToPasteboard() else { return alert("The image could not be copied.") }
        alert("Copied to pasteboard!")
    }

    /// Загружает изображение из ресурсов и копирует его в буфер обмена.
    ///
    /// - Parameter imageName: Имя изображения в наборе ресурсов.
    func copyImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        copyImage(image)
    }

    /// Сохраняет изображение в медиатеку при наличии полного доступа.
    ///
    /// - Parameter image: Изображение для сохранения.
    func saveImage(_ image: UIImage) {
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to save images.") }
        image.saveToPhotos(completion: handleImageDidSave)
        alert("Saved to photos!")
    }

    /// Загружает изображение из ресурсов и сохраняет его в медиатеку.
    ///
    /// - Parameter imageName: Имя изображения в наборе ресурсов.
    func saveImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        saveImage(image)
    }
}

private extension MyKeyboardActionHandler {

    /// Сообщает результат завершившегося сохранения изображения.
    ///
    /// - Parameter error: Ошибка сохранения или `nil` при успехе.
    func handleImageDidSave(WithError error: Error?) {
        if error == nil { alert("Saved!") }
        else { alert("Failed!") }
    }
}

/// Символы апострофа, которые могут быть частью ингушского ввода.
private enum KeyboardCharacters {

    static let apostrophes: Set<String> = ["'", "’", "‘"]
}


private extension UIImage {

    /// Записывает PNG-представление изображения в указанный буфер обмена.
    ///
    /// - Parameter pasteboard: Буфер обмена для записи.
    /// - Returns: `true`, если изображение удалось преобразовать и записать.
    func copyToPasteboard(_ pasteboard: UIPasteboard = .general) -> Bool {
        guard let data = pngData() else { return false }
        pasteboard.setData(data, forPasteboardType: "public.png")
        return true
    }
}


private extension UIImage {

    /// Сохраняет изображение в системную медиатеку.
    ///
    /// - Parameter completion: Замыкание, получающее ошибку сохранения.
    func saveToPhotos(completion: @escaping (Error?) -> Void) {
        ImageService.default.saveImageToPhotos(self, completion: completion)
    }
}

/// Хранит замыкания завершения для целевого метода API сохранения изображений.
private class ImageService: NSObject {
    
    public typealias Completion = (Error?) -> Void
    
    public static private(set) var `default` = ImageService()
    
    private var completions = [Completion]()

    /// Начинает сохранение изображения в системную медиатеку.
    ///
    /// - Parameters:
    ///   - image: Сохраняемое изображение.
    ///   - completion: Замыкание, которое получит результат операции.
    public func saveImageToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageToPhotosDidComplete), nil)
    }

    /// Передаёт результат системного сохранения первому ожидающему замыканию.
    ///
    /// - Parameters:
    ///   - image: Изображение, для которого завершилась операция.
    ///   - error: Системная ошибка сохранения или `nil`.
    ///   - contextInfo: Указатель контекста системного API.
    @objc func saveImageToPhotosDidComplete(_ image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        guard completions.count > 0 else { return }
        completions.removeFirst()(error)
    }
}
