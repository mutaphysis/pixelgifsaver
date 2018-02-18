import ScreenSaver

@objc
class PixelGifSaver: ScreenSaverView {
  var pixelScene: PixelScene!;
  
  override init?(frame: NSRect, isPreview: Bool) {
    super.init(frame: frame, isPreview: isPreview)
    for subview in self.subviews {
      subview.removeFromSuperview()
    }
    
    pixelScene = PixelScene(bounds: frame)
    self.addSubview(pixelScene.view)
  }  
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
