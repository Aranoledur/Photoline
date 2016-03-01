//
//  UIImage+AvarageColor.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 06.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

extension UIImage {
    func areaAverage() -> UIColor {
        var bitmap = [UInt8](count: 4, repeatedValue: 0)
        
        //too slow maybe later
        /*
        if #available(iOS 9.0, *) {
            // Get average color.
            let context = CIContext()
            let inputImage = CIImage ?? CoreImage.CIImage(CGImage: CGImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        }*/
        
        // Create 1x1 context that interpolates pixels when drawing to it.
        let context = CGBitmapContextCreate(&bitmap, 1, 1, 8, 4, CGColorSpaceCreateDeviceRGB(), CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)!
        let inputImage = CGImage ?? CIContext().createCGImage(CIImage!, fromRect: CIImage!.extent)
        
        // Render to bitmap.
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: 1, height: 1), inputImage)
        
        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
    
    class func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
