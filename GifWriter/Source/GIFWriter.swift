//
//  GIFWriter.swift
//
//
//  Created by Gustavo Barcena on 9/9/14.
//
//

import UIKit
import MobileCoreServices
import ImageIO

public class GIFWriter: NSObject {
    
    private var destination: CGImageDestinationRef!
    private var images: [CGImage]
    private var frameDelay: Double
    
    public var progressBlock: ((frameIndex: Int, frameCount: Int)->Void)?
    
    public init?(images: [UIImage], frameDelay: Double = 0.25) {
        let cgImages = images.flatMap({ $0.CGImage })
        guard images.count == cgImages.count else {
            self.images = []
            self.frameDelay = frameDelay
            super.init()
            return nil
        }
        self.images = cgImages
        self.frameDelay = frameDelay
        super.init()
    }
    
    public func makeGIF(destinationURL: NSURL) {
        beginWrite(destinationURL)
        let frameCount = images.count
        
        for (index, image) in images.enumerate() {
            writeImage(image, frameDelay: frameDelay)
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBlock?(frameIndex:index+1, frameCount:frameCount)
            }
        }
        
        endWrite()
    }
    
    private func beginWrite(destinationURL: NSURL) {
        let fileProperties = GIFWriter.gifProperties()
        destination = CGImageDestinationCreateWithURL(destinationURL, kUTTypeGIF, Int(images.count), nil)
        CGImageDestinationSetProperties(destination, fileProperties)
    }
    
    private func writeImage(image: CGImage, frameDelay: NSTimeInterval) {
        let frameProperties = GIFWriter.frameProperties(frameDelay)
        CGImageDestinationAddImage(destination, image, frameProperties)
    }
    
    private func endWrite() {
        CGImageDestinationFinalize(destination)
    }
    
    // Mark: Class Helpers
    
    private class func frameProperties(frameDelay: NSTimeInterval) -> CFDictionary {
        let dict: CFDictionary = [kCGImagePropertyGIFDelayTime as String: frameDelay]
        return [kCGImagePropertyGIFDictionary as String :dict]
    }
    
    private class func gifProperties() -> CFDictionary {
        let dict: CFDictionary = [kCGImagePropertyGIFLoopCount as String: 0]
        return [kCGImagePropertyGIFDictionary as String:dict]
    }
}
