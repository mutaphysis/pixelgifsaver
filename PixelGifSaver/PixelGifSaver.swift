import ScreenSaver

@objc(PixelGifSaver)
class PixelGifSaver: ScreenSaverView {
  public private(set) var pixelScene: PixelScene!;
  private var gifFileUrls: [URL]!;
  
  override init?(frame: NSRect, isPreview: Bool) {
    super.init(frame: frame, isPreview: isPreview)
    
    let gifFileUrls = PixelGifSaver.collectGifsFromDirectory(directory: "/Users/loplop/Dropbox/stuff/Pixel Scenes/")
    self.pixelScene = PixelScene(bounds: frame, urls: gifFileUrls)!
    self.addSubview(pixelScene)
  }  
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    let gifFileUrls = PixelGifSaver.collectGifsFromDirectory(directory: "/Users/loplop/Dropbox/stuff/Pixel Scenes/")
    self.pixelScene = PixelScene(bounds: frame, urls: gifFileUrls)!
    self.addSubview(pixelScene)
  }
  
  static func collectGifsFromDirectory(directory: String) -> [URL] {
    let rootUrl = URL.init(fileURLWithPath: directory);
    let enumerator = FileManager.default.enumerator(atPath: directory)
    let relativeFilePaths = enumerator?.allObjects as! [String]
    let gifAnimationFiles = relativeFilePaths.filter{$0.lowercased().hasSuffix(".gif")}
    
    var absoluteUrls = gifAnimationFiles.map { (file: String) -> URL in
      var path = rootUrl;
      path.appendPathComponent(file)
      return path
    }
    
    absoluteUrls.shuffleInPlace()
    return absoluteUrls
  }
  
  var preferencesController: PreferencesWindowController?
  
  override var hasConfigureSheet: Bool { get {
    return true
    } }
  
  override var configureSheet: NSWindow? { get {
    if let controller = preferencesController {
      return controller.window
    }
    
    let controller = PreferencesWindowController(windowNibName: NSNib.Name("PreferencesWindow"))
    
    preferencesController = controller
    return controller.window
    } }
}
