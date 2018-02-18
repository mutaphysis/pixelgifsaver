import ScreenSaver
import SpriteKit

enum AnimationDirection {
  case vertical
  case horizontal
}

extension SKAction {
  // amplitude  - the amount the height will vary by
  // timePeriod - the time it takes for one complete cycle
  // midPoint   - the point around which the oscillation occurs.
  static func oscillation(direction: AnimationDirection, amplitude a: CGFloat, timePeriod t: Double, midPoint: CGPoint) -> SKAction {
    let action = SKAction.customAction(withDuration: t) { node, currentTime in
      let displacement = a * sin(2 * .pi * currentTime / CGFloat(t))
      if (direction == .vertical) {
        node.position.y = midPoint.y + displacement
      } else {
        node.position.x = midPoint.x + displacement
      }
    }
    return action
  }
}

let DurationPerAnimation = 10.0;

class PixelScene {
  public let view: SKView
  private let scene: SKScene
  
  private func putAnimatedGif(url: URL) {
    let gifResource = GifImage(url: url)!
    
    let aspectRatio = gifResource.size.width / gifResource.size.height;
    let direction = (aspectRatio > 1.0) ? AnimationDirection.horizontal : AnimationDirection.vertical
    
    var rectangleSize: CGSize
    var overlap: CGFloat
    switch direction {
      case .horizontal:
        rectangleSize = CGSize(width: 1.0 * aspectRatio, height: 1.0)
        overlap = rectangleSize.width - 1.0
      case .vertical:
        rectangleSize = CGSize(width: 1.0, height: 1.0 / aspectRatio)
      overlap = rectangleSize.height - 1.0
    }
    let rectangle = SKSpriteNode(color: SKColor.red, size: rectangleSize)
    rectangle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    rectangle.position = CGPoint(x: 0.5, y: 0.5)
    
    let scene = self.scene
    scene.addChild(rectangle)
    
    let oscillate = SKAction.oscillation(direction: direction,
                                         amplitude: overlap/2,
                                         timePeriod: 10.0,
                                         midPoint: rectangle.position)
    rectangle.run(SKAction.repeatForever(oscillate))
    rectangle.run(SKAction.repeatForever(gifResource.animation()))
    // rectangle.run(SKAction.sequence([SKAction.wait(forDuration: DurationPerAnimation), SKAction.removeFromParent()]))
  }
  
  static private func prepareScene() -> SKScene {
    let scene = SKScene.init()
    scene.scaleMode = .aspectFill
    scene.backgroundColor = SKColor.green
    
    return scene
  }
  
  init?(bounds: NSRect) {
    self.view = SKView.init(frame: bounds)
    self.view.autoresizingMask = [.width, .height]
    self.view.autoresizesSubviews = true
    
    self.scene = PixelScene.prepareScene()
    
    self.view.showsFPS = true

    self.view.presentScene(self.scene)
    
    let fileUrl = Foundation.URL(fileURLWithPath: "/Users/loplop/Dropbox/stuff/Pixel Scenes/fb4926b3f11054e881ba8f0edf29daa8.gif")
    self.putAnimatedGif(url: fileUrl)
  }
}

