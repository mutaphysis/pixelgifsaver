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
let CrossFadeDuration = 1.0;

class PixelScene {
  public let view: SKView
  private let scene: SKScene
  private let urls: [URL]
  
  private var currentAnimation: SKSpriteNode? = nil
  private var currentIndex = 0;
  private var isLoadingGif = false;
  
  private func putAnimatedGif(url: URL) {
    if isLoadingGif { return }
    
    isLoadingGif = true
    let background = DispatchQueue.global();
    background.async {
      // load new gif
      let gifResource = GifImage(url: url)
      
      DispatchQueue.main.async {
        if (gifResource == nil) {
          self.isLoadingGif = false
          self.nextGif()
          return;
        }
        
        // figure out how it fits best
        let aspectRatio = gifResource!.size.width / gifResource!.size.height;
        let direction = (aspectRatio > 1.0) ? AnimationDirection.horizontal : AnimationDirection.vertical
        
        // determine size and movement
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
        
        // insert to scene
        let scene = self.scene
        let gifNode = SKSpriteNode(color: SKColor.red, size: rectangleSize)
        gifNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gifNode.position = CGPoint(x: 0.5, y: 0.5)
        scene.addChild(gifNode)
        
        // setup all animations on the node
        
        // move
        gifNode.run(SKAction.repeatForever(SKAction.oscillation(direction: direction,
                                                                amplitude: overlap/2,
                                                                timePeriod: 10.0,
                                                                midPoint: gifNode.position)))
        // switch through gif frame
        gifNode.run(SKAction.repeatForever(gifResource!.animation()))
        // fade in
        gifNode.alpha = 0.0
        gifNode.run(SKAction.fadeIn(withDuration: CrossFadeDuration))
        
        if self.currentAnimation != nil {
          self.currentAnimation?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: CrossFadeDuration),
            SKAction.removeFromParent()]))
        }
        self.currentAnimation = gifNode
        self.isLoadingGif = false
      }
    }
  }
  
  static private func prepareScene() -> SKScene {
    let scene = SKScene.init()
    scene.scaleMode = .aspectFill
    scene.backgroundColor = SKColor.black
    
    return scene
  }
  
  func nextGif() {
    currentIndex = (currentIndex + 1) % urls.count
    
    if (urls.count > 0) {
      self.putAnimatedGif(url: urls[currentIndex])
      // self.scene.run(<#T##action: SKAction##SKAction#>)
    }
  }
  
  init?(bounds: NSRect, urls: [URL]) {
    self.urls = urls
    
    self.view = SKView.init(frame: bounds)
    self.view.autoresizingMask = [.width, .height]
    self.view.autoresizesSubviews = true
    
    self.scene = PixelScene.prepareScene()
    
    self.view.showsFPS = true
    self.view.presentScene(self.scene)
    
    // start first animation
    self.nextGif()
  }
}

