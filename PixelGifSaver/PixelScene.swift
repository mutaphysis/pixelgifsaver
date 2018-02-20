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

let MinDurationPerGif = 30.0
let CrossFadeDuration = 1.0
let MinOscillateDuration = 2.0
let OscillatePixelPerSecond = 30.0


class PixelScene : SKView {
  private let urls: [URL]
  
  private var currentAnimationNode: SKSpriteNode? = nil
  private var currentAspectRatio: CGFloat? = nil
  private var currentIndex = 0;
  private var isLoadingGif = false;
  
  private func putAnimatedGif(url: URL) -> Bool {
    if isLoadingGif { return false }
    
    isLoadingGif = true
    let background = DispatchQueue.global();
    background.async {
      // load new gif
      let gifResource = GifImage(url: url)
      
      DispatchQueue.main.async {
        // loading the gif failed
        if (gifResource == nil || self.scene == nil) {
          self.isLoadingGif = false
          self.nextGif()
          return;
        }
        
        let pixelScene = self.scene!
        
        pixelScene.removeAction(forKey: "nextGif")
        self.currentAspectRatio = gifResource!.size.width / gifResource!.size.height
        
        // insert to scene
        let gifNode = SKSpriteNode(color: SKColor.red,
                                   size: CGSize(width: gifResource!.size.width, height: gifResource!.size.height))
        gifNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pixelScene.addChild(gifNode)
        
        // set size and scroll anim
        let oscillateAnimationDuration = self.resizeNode(node: gifNode)
        
        // setup all animations on the node
        
        // switch through gif frame
        gifNode.run(SKAction.repeatForever(gifResource!.animation()))
        // fade in
        gifNode.alpha = 0.0
        gifNode.run(SKAction.fadeIn(withDuration: CrossFadeDuration))
        
        // remove existing node
        if self.currentAnimationNode != nil {
          self.currentAnimationNode?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: CrossFadeDuration),
            SKAction.removeFromParent()]))
        }
        self.currentAnimationNode = gifNode
        self.isLoadingGif = false
        
        let durationPerGif = max(MinDurationPerGif, 2 * oscillateAnimationDuration)
        pixelScene.run(SKAction.customAction(withDuration: durationPerGif, actionBlock: { _, time in
          if (Double(time) >= durationPerGif) {
            self.nextGif();
          }
        }), withKey: "nextGif")
      }
    }
    
    return true
  }
  
  override func resize(withOldSuperviewSize oldSize: NSSize) {
    super.resize(withOldSuperviewSize: oldSize)
    
    if (self.currentAnimationNode != nil) {
      resizeNode(node: self.currentAnimationNode!)
    }
  }
  
  func resizeNode(node: SKSpriteNode) -> Double {
    let pixelScene = self.scene!
    
    // figure out how it fits best
    let aspectRatio = self.currentAspectRatio!
    let direction = (aspectRatio > 1.0) ? AnimationDirection.horizontal : AnimationDirection.vertical
    let sceneSize = pixelScene.size
    
    // determine size and movement
    var rectangleSize: CGSize
    var overlap: CGFloat
    switch direction {
    case .horizontal:
      rectangleSize = CGSize(width: sceneSize.width * aspectRatio, height: sceneSize.height)
      overlap = rectangleSize.width - sceneSize.width
    case .vertical:
      rectangleSize = CGSize(width: sceneSize.width, height: sceneSize.height / aspectRatio)
      overlap = rectangleSize.height - sceneSize.height
    }
    
    node.size = rectangleSize
    node.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
    
    print("placing node scene:\(sceneSize) node:\(rectangleSize) overlap:\(overlap) aspect:\(aspectRatio) ")
    
    let animationDuration = max(Double(overlap)/OscillatePixelPerSecond, MinOscillateDuration);
    node.removeAction(forKey: "oscillate")
    node.run(SKAction.repeatForever(
      SKAction.oscillation(direction: direction,
                           amplitude: overlap/2,
                           timePeriod: animationDuration,
                           midPoint: node.position)),
                withKey: "oscillate")
    
    return animationDuration;
  }
  
  func nextGif() {
    let nextIndex = (currentIndex + 1) % urls.count
    
    if (nextIndex < urls.count) {
      if self.putAnimatedGif(url: urls[nextIndex]) {
        currentIndex = nextIndex
        print("Switching to next gif \(urls[nextIndex])")
      }
    }
  }
  
  init?(bounds: NSRect, urls: [URL]) {
    self.urls = urls
    
    super.init(frame: bounds)
    self.autoresizingMask = [.width, .height]
    self.autoresizesSubviews = true
    
    let pixelScene = SKScene.init()
    pixelScene.scaleMode = .resizeFill
    pixelScene.backgroundColor = SKColor.black
    
    self.preferredFramesPerSecond = 30
    self.showsFPS = true
    self.presentScene(pixelScene)
    
    // start first animation
    self.nextGif()
  }
  
  required init?(coder decoder: NSCoder) {
    self.urls = []
    super.init(coder: decoder)
  }
}

