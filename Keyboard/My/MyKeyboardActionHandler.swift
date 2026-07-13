//
//  MyActionActionHandler.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit
import UIKit
import SwiftUI

class MyKeyboardActionHandler: StandardKeyboardActionHandler {
    
    @AppStorage(KeyboardSettingsKey.isAudioFeedback, store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardAudioFeedback: Bool = false

    var isAutocapitalizationEnabled: Bool = true
    
    // MARK: - Overrides
    
    override func shouldTriggerFeedback(for gesture: Keyboard.Gesture, on action: KeyboardAction) -> Bool {
        if isKeyboardAudioFeedback {
            return super.shouldTriggerFeedback(for: gesture, on: action)
        } else {
            return false
        }
    }
    
    override func action(for gesture: Keyboard.Gesture, on action: KeyboardAction) -> KeyboardAction.GestureAction? {
        let standard = super.action(for: gesture, on: action)
        switch gesture {
            case .longPress: return longPressAction(for: action) ?? standard
            case .release: return releaseAction(for: action) ?? standard
            default: return standard
        }
    }

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

        // KeyboardKit пересчитывает регистр после пробела, удаления и ввода знаков.
        // При отключённой настройке не даём этим переходам снова включить Shift.
        guard isAutocapitalizationEnabled else {
            return .lowercased
        }

        return super.preferredKeyboardCase(after: gesture, on: action)
    }

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
    
    func longPressAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        switch action {
            case .image(_, _, let imageName): return { [weak self] _ in self?.saveImage(named: imageName) }
            default: return nil
        }
    }
    
    func releaseAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        switch action {
            case .image(_, _, let imageName): return { [weak self] _ in self?.copyImage(named: imageName) }
            default: return nil
        }
    }
    
    
    // MARK: - Functions
    
    /**
     Override this function to implement a way to alert text
     messages in the keyboard extension. You can't use logic
     that you use in real apps, e.g. `UIAlertController`.
     */
    func alert(_ message: String) {}
    
    func copyImage(_ image: UIImage) {
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to copy images.") }
        guard image.copyToPasteboard() else { return alert("The image could not be copied.") }
        alert("Copied to pasteboard!")
    }
    
    func copyImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        copyImage(image)
    }
    
    func saveImage(_ image: UIImage) {
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to save images.") }
        image.saveToPhotos(completion: handleImageDidSave)
        alert("Saved to photos!")
    }
    
    func saveImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        saveImage(image)
    }
}

private extension MyKeyboardActionHandler {
    
    func handleImageDidSave(WithError error: Error?) {
        if error == nil { alert("Saved!") }
        else { alert("Failed!") }
    }
}

private enum KeyboardCharacters {

    static let apostrophes: Set<String> = ["'", "’", "‘"]
}


private extension UIImage {
    
    func copyToPasteboard(_ pasteboard: UIPasteboard = .general) -> Bool {
        guard let data = pngData() else { return false }
        pasteboard.setData(data, forPasteboardType: "public.png")
        return true
    }
}


private extension UIImage {
    
    func saveToPhotos(completion: @escaping (Error?) -> Void) {
        ImageService.default.saveImageToPhotos(self, completion: completion)
    }
}


/**
 This class is used as a target/selector holder by the image
 extension above.
 */
private class ImageService: NSObject {
    
    public typealias Completion = (Error?) -> Void
    
    public static private(set) var `default` = ImageService()
    
    private var completions = [Completion]()
    
    public func saveImageToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageToPhotosDidComplete), nil)
    }
    
    @objc func saveImageToPhotosDidComplete(_ image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        guard completions.count > 0 else { return }
        completions.removeFirst()(error)
    }
}
