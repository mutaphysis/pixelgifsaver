import AVFoundation
import SpriteKit

class GifImage {
  private let textures: [SKTexture]
  private let frameDurations: [TimeInterval]
  public let size: CGSize
  
  func animation() -> SKAction {
    var actions = [SKAction]();
    for i in 0..<textures.count {
      actions.append(SKAction.setTexture(textures[i]))
      actions.append(SKAction.wait(forDuration: frameDurations[i]))
    }

    return SKAction.sequence(actions);
  }
  
  init?(url:URL) {
    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
      print("Failed creating cgimage from \(url)")
      return nil
    }
    
    let frameCount = CGImageSourceGetCount(src)
    if (frameCount <= 0) {
      print("Found no frames in \(url)")
      return nil
    }
    
    let minimalFrameDuration = Float(0.075);
    var totalDuration : Float = 0
    var tmpDurations = [TimeInterval]()
    var tmpTextures = [SKTexture]()
    
    // loop through all frames
    for i in 0..<frameCount {
      var frameDuration : Float = minimalFrameDuration;
      
      let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
      guard let frameProperties = cfFrameProperties as? [String:AnyObject] else {return nil}
      guard let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject] else {
        print("Failed collecting gif data for frame \(i) in \(url)")
        return nil
      }
      
      // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
      if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
        frameDuration = delayTimeUnclampedProp.floatValue
      } else {
        if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
          frameDuration = delayTimeProp.floatValue
        } 
      }
      
      // ensure the individual frame duration is not to small
      if frameDuration < minimalFrameDuration {
        frameDuration = minimalFrameDuration;
      }

      // collect frames
      if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
        tmpDurations.append(TimeInterval(frameDuration))
        let texture = SKTexture(cgImage: frame)
        // ensure scaling does not blur
        texture.filteringMode = .nearest
        tmpTextures.append(texture)
      } else {
        print("Failed collecting texture for frame \(i)")
        return nil;
      }
      
      totalDuration = totalDuration + frameDuration
    }
    
    self.size = tmpTextures.last!.size()
    self.textures = tmpTextures
    self.frameDurations = tmpDurations
  }
}

