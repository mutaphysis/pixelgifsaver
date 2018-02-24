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
        node.position.y = round(midPoint.y + displacement)
      } else {
        node.position.x = round(midPoint.x + displacement)
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
        
        let durationPerGif = max(MinDurationPerGif, oscillateAnimationDuration)
        pixelScene.run(SKAction.sequence([
          SKAction.wait(forDuration: durationPerGif),
          SKAction.customAction(withDuration: durationPerGif, actionBlock: { _, _ in
            self.nextGif();
        })]), withKey: "nextGif")
      }
    }
    
    return true
  }
  
  override func resize(withOldSuperviewSize oldSize: NSSize) {
    super.resize(withOldSuperviewSize: oldSize)
    
    if (self.currentAnimationNode != nil) {
      _ = resizeNode(node: self.currentAnimationNode!)
    }
  }
  
  func resizeNode(node: SKSpriteNode) -> Double {
    let pixelScene = self.scene!
    
    // figure out how it fits best
    let sceneSize = pixelScene.size
    let contentAspectRatio = self.currentAspectRatio!
    let sceneAspectRatio = sceneSize.width / sceneSize.height
    let unscaledNodeSize = CGSize(width: node.size.width / node.xScale, height: node.size.height / node.yScale)
    let direction = (contentAspectRatio > sceneAspectRatio) ?
      AnimationDirection.horizontal :
      AnimationDirection.vertical
    
    // determine size and movement
    var scale: CGFloat
    var overlap: CGFloat
    switch direction {
    case .horizontal:
      scale = sceneSize.height / unscaledNodeSize.height
      node.setScale(scale)
      overlap = node.size.width - sceneSize.width
    case .vertical:
      scale = sceneSize.width / unscaledNodeSize.width
      node.setScale(scale)
      overlap = node.size.height - sceneSize.height
    }
    
    node.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
    print("placing node scene:\(sceneSize) node:\(node.size) scale:\(scale) overlap:\(overlap) contenAspect:\(contentAspectRatio) sceneAscpect:\(sceneAspectRatio)")
    
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

