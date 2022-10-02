//
//  MyActionHandler.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit
import UIKit
import SwiftUI

class MyKeyboardActionHandler: StandardKeyboardActionHandler {
    
    @AppStorage("SettingsView.Keyboard.isAudioFeedback", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardAudioFeedback: Bool = false
    
    public init(inputViewController: KeyboardInputViewController) {
        super.init(inputViewController: inputViewController)
    }
    
    // MARK: - Overrides
    
    override func shouldTriggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) -> Bool {
        if isKeyboardAudioFeedback {
            return super.shouldTriggerFeedback(for: gesture, on: action)
        } else {
            return false
        }
    }
    
    override func action(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction.GestureAction? {
        let standard = super.action(for: gesture, on: action)
        switch gesture {
            case .longPress: return longPressAction(for: action) ?? standard
            case .tap: return tapAction(for: action) ?? standard
            default: return standard
        }
    }
    
    override func handle(_ gesture: KeyboardGesture, on action: KeyboardAction) {
        // Customize the action handling if needed
        super.handle(gesture, on: action)
    }
    
    
    // MARK: - Custom actions
    
    func longPressAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        switch action {
            case .image(_, _, let imageName): return { [weak self] _ in self?.saveImage(named: imageName) }
            default: return nil
        }
    }
    
    func tapAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
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
