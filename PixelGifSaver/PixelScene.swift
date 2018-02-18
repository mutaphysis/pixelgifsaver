import ScreenSaver
import SpriteKit

extension SKAction {
  // amplitude  - the amount the height will vary by, set this to 200 in your case.
  // timePeriod - the time it takes for one complete cycle
  // midPoint   - the point around which the oscillation occurs.
  static func oscillation(amplitude a: CGFloat, timePeriod t: Double, midPoint: CGPoint) -> SKAction {
    let action = SKAction.customAction(withDuration: t) { node, currentTime in
      let displacement = a * sin(2 * .pi * currentTime / CGFloat(t))
      node.position.y = midPoint.y + displacement
    }
    
    return action
  }
}

class PixelScene {
  public let view: SKView
  private let scene: SKScene
  
  private func putAnimatedGif(url: URL) {
    let gifResource = GifImage(url: url)!

    let rectangle = SKSpriteNode(color: SKColor.red, size: CGSize(width: 0.5, height: 0.5))
    rectangle.anchorPoint = CGPoint(x: 0, y: 0)
    rectangle.position = CGPoint(x: 0.25, y: 0.25)
    
    let scene = self.scene
    scene.addChild(rectangle)
    
    let oscillate = SKAction.oscillation(amplitude: 0.5,
                                         timePeriod: 3,
                                         midPoint: rectangle.position)
    rectangle.run(SKAction.repeatForever(oscillate))
    rectangle.run(SKAction.repeatForever(gifResource.animation()))
  }
  
  static private func prepareScene() -> SKScene {
    let scene = SKScene.init()
    
    scene.scaleMode = .aspectFit
    scene.backgroundColor = SKColor.green
    
    return scene
  }
  
  init?(bounds: NSRect) {
    self.view = SKView.init(frame: bounds)
    self.scene = PixelScene.prepareScene()
    
    self.view.showsFPS = true

    self.view.presentScene(self.scene)
    
    let fileUrl = Foundation.URL(fileURLWithPath: "/Users/loplop/Dropbox/stuff/Pixel Scenes/fb4926b3f11054e881ba8f0edf29daa8.gif")
    self.putAnimatedGif(url: fileUrl)
  }
}

