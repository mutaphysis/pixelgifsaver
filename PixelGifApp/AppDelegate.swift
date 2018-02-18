

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  @IBOutlet weak var window: NSWindow!
  
  lazy var screenSaverView = PixelGifSaver(frame: NSRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 480, height: 480)), isPreview: false)
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if let screenSaverView = screenSaverView {
      let content = window.contentView!;
      screenSaverView.autoresizingMask = [.width, .height]
      screenSaverView.autoresizesSubviews = true
      screenSaverView.frame = content.bounds;
      
      NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
        self.keyDown(with: $0)
        return $0
      }
      
      content.addSubview(screenSaverView);
    }
  }
  
  func keyDown(with event: NSEvent) {
     self.screenSaverView?.pixelScene.nextGif()
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

