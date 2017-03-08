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

open class GIFWriter: NSObject {
    
    fileprivate var destination: CGImageDestination!
    fileprivate var images: [CGImage]
    fileprivate var frameDelay: Double
    
    open var progressBlock: ((_ frameIndex: Int, _ frameCount: Int)->Void)?
    
    public init?(images: [UIImage], frameDelay: Double = 0.25) {
        let cgImages = images.flatMap({ $0.cgImage })
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
    
    open func makeGIF(_ destinationURL: URL) {
        beginWrite(destinationURL)
        let frameCount = images.count
        
        for (index, image) in images.enumerated() {
            writeImage(image, frameDelay: frameDelay)
            DispatchQueue.main.async {
                self.progressBlock?(index+1, frameCount)
            }
        }
        
        endWrite()
    }
    
    fileprivate func beginWrite(_ destinationURL: URL) {
        let fileProperties = GIFWriter.gifProperties()
        destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeGIF, Int(images.count), nil)
        CGImageDestinationSetProperties(destination, fileProperties)
    }
    
    fileprivate func writeImage(_ image: CGImage, frameDelay: TimeInterval) {
        let frameProperties = GIFWriter.frameProperties(frameDelay)
        CGImageDestinationAddImage(destination, image, frameProperties)
    }
    
    fileprivate func endWrite() {
        CGImageDestinationFinalize(destination)
    }
    
    // Mark: Class Helpers
    
    fileprivate class func frameProperties(_ frameDelay: TimeInterval) -> CFDictionary {
        let dict = [kCGImagePropertyGIFDelayTime as String: frameDelay]
        return [kCGImagePropertyGIFDictionary as String: dict] as CFDictionary
    }
    
    fileprivate class func gifProperties() -> CFDictionary {
        let dict = [kCGImagePropertyGIFLoopCount as String: 0]
        return [kCGImagePropertyGIFDictionary as String: dict] as CFDictionary
    }
}
