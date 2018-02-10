import ScreenSaver
import SceneKit

class PixelScene {
  var scnView: SCNView!
  
  func putAnimatedGif() {
    let plane = SCNPlane(width: 2, height: 2)
    
    let bundleURL = Bundle.main.url(forResource: "engine", withExtension: "gif")
    let animation : CAKeyframeAnimation = GifLoader.loadGifAnimation(url: bundleURL!)!
    
    let layer = CALayer()
    layer.bounds = CGRect(x: 0, y: 0, width: 900, height: 900)
  }
  
  func prepareSceneKitView(bounds: NSRect) {
    // openGL seems to perform much better on SS + SceneKit.  On multiple monitors this was causing fans to kick in using default ( Metal )
    _ = [SCNView.Option.preferredRenderingAPI: SCNRenderingAPI.openGLCore32.rawValue]
    
    let scnView = SCNView.init(frame: bounds, options: nil)
    scnView.showsStatistics = true
    scnView.antialiasingMode = .none
    scnView.backgroundColor = NSColor.green
    
    self.scnView = scnView;
  }
  
  init?(bounds: NSRect) {
    prepareSceneKitView(bounds: bounds)
  }
}

