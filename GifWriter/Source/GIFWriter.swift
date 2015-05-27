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

@objc protocol GIFWriterDelegate {
    func didStartWritingGIF(writer: GIFWriter)
    func didEndWritingGIF(writer: GIFWriter)
    
    optional func didWriteImage(writer: GIFWriter, frameIndex: Int, frameCount:Int)
}

class GIFWriter : NSObject {
    
    var delegate : GIFWriterDelegate?
    private var destination : CGImageDestinationRef!
    private var images: [UIImage]
    
    init(images:[UIImage])
    {
        self.images = images;
    }
    
    func makeGIF(destinationURL:NSURL)
    {
        beginWrite(destinationURL)
        var frameCount = images.count
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.didStartWritingGIF(self)
        }
        for (index, image) in enumerate(images)
        {
            NSThread.sleepForTimeInterval(0.25)
            writeImage(image.CGImage, frameDelay: 0.25);
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.didWriteImage?(self, frameIndex: index+1, frameCount:frameCount)
            }
        }
        endWrite();
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.didEndWritingGIF(self)
        }
    }
    
    private func beginWrite(destinationURL:NSURL)
    {
        var fileProperties = GIFWriter.gifProperties()
        destination = CGImageDestinationCreateWithURL(destinationURL, kUTTypeGIF, Int(images.count), nil)
        CGImageDestinationSetProperties(destination, fileProperties)
    }
    
    private func writeImage(image:CGImage, frameDelay : NSTimeInterval)
    {
        var frameProperties = GIFWriter.frameProperties(frameDelay);
        CGImageDestinationAddImage(destination, image, frameProperties);
    }
    
    private func endWrite()
    {
        CGImageDestinationFinalize(destination)
    }
    
    // Mark: Class Helpers
    
    private class func frameProperties(frameDelay:NSTimeInterval) -> CFDictionary
    {
        var dict : CFDictionary = [kCGImagePropertyGIFDelayTime as String :frameDelay]
        return [kCGImagePropertyGIFDictionary as String :dict]
    }
    
    private class func gifProperties() -> CFDictionary
    {
        var dict : CFDictionary = [kCGImagePropertyGIFLoopCount as String : 0];
        return [kCGImagePropertyGIFDictionary as String:dict]
    }
}
