import Foundation
import AppKit

@objc(PreferencesWindowController)
class PreferencesWindowController: NSWindowController {
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    override init(window: NSWindow?) {
        super.init(window: window)        
    }
}
