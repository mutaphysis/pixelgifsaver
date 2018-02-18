import AVFoundation
import SpriteKit

class GifImage {
  private let textures: [SKTexture]
  private let frameDurations: [TimeInterval]
  
  func animation() -> SKAction {
    var actions = [SKAction]();
    for i in 0..<textures.count {
      actions.append(SKAction.setTexture(textures[i]))
      actions.append(SKAction.wait(forDuration: frameDurations[i]))
    }
    return SKAction.sequence(actions);
  }
  
  init?(url:URL) {
    print("Starting gif", url, Date())
    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    
    let frameCount = CGImageSourceGetCount(src)
    var totalDuration : Float = 0
    var tmpDurations = [TimeInterval]()
    var tmpTextures = [SKTexture]()

    // loop through all frames
    for i in 0..<frameCount {
      var frameDuration : Float = 0.1;
      
      let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
      guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
      guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
        else { return nil }
      
      // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
      if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
        frameDuration = delayTimeUnclampedProp.floatValue
      } else {
        if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
          frameDuration = delayTimeProp.floatValue
        }
      }
      
      // ensure the individual frame duration is not to small
      // TODO where do these values come from?
      if frameDuration < 0.075 {
        frameDuration = 0.075;
      }

      // collect frames
      if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
        tmpDurations.append(TimeInterval(frameDuration))
        tmpTextures.append(SKTexture(cgImage: frame))
      }
      
      totalDuration = totalDuration + frameDuration
    }
    self.textures = tmpTextures
    self.frameDurations = tmpDurations
    
    print("Done gif", url, Date())
  }
}

