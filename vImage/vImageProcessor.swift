//
//  ImageProcessor.swift
//  vImage
//
//  Created by What on 2018/12/28.
//  Copyright © 2018 dumbass. All rights reserved.
//

import Accelerate.vImage

@discardableResult
func vImageBuffer_InitWithCVImage(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ imageBuffer: CVImageBuffer)
    -> vImage_Error {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let byteOrder32Little = CGBitmapInfo.byteOrder32Little.rawValue
        let alphaInfo = CGImageAlphaInfo.first.rawValue
        
        var desiredFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                                 bitsPerPixel: 32,
                                                 colorSpace: .passRetained(CGColorSpaceCreateDeviceRGB()),
                                                 bitmapInfo: .init(rawValue: byteOrder32Little | alphaInfo),
                                                 version: 0,
                                                 decode: nil,
                                                 renderingIntent: .defaultIntent)
        
        let cvImageFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(imageBuffer).takeRetainedValue()
        let error = vImageCVImageFormat_SetColorSpace(cvImageFormat, colorSpace)
        
        guard error == kvImageNoError else {
            return error
        }
        
        return vImageBuffer_InitWithCVPixelBuffer(sourceBuffer,
                                                  &desiredFormat,
                                                  imageBuffer,
                                                  cvImageFormat,
                                                  nil,
                                                  .init(kvImageNoFlags))
}

@discardableResult
func vImageFlipHorizontally_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>)
    -> vImage_Error {
    
        let error = vImageBuffer_Init(destinationBuffer,
                                      sourceBuffer.pointee.height,
                                      sourceBuffer.pointee.width,
                                      32,
                                      .init(kvImageNoFlags))
        
        guard error == kvImageNoError else {
            return error
        }
        
        return vImageHorizontalReflect_ARGB8888(sourceBuffer,
                                                destinationBuffer,
                                                .init(kvImageNoFlags))
}

@discardableResult
func vImageFlipVertically_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>)
    -> vImage_Error {
        
        let error = vImageBuffer_Init(destinationBuffer,
                                      sourceBuffer.pointee.height,
                                      sourceBuffer.pointee.width,
                                      32,
                                      .init(kvImageNoFlags))
        
        guard error == kvImageNoError else {
            return error
        }
        
        return vImageVerticalReflect_ARGB8888(sourceBuffer,
                                              destinationBuffer,
                                              .init(kvImageNoFlags))
}

@discardableResult
func vImageRotate90_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ rotationConstant: UInt8)
    -> vImage_Error {
        
        let error = vImageBuffer_Init(destinationBuffer,
                                      sourceBuffer.pointee.height,
                                      sourceBuffer.pointee.width,
                                      32,
                                      .init(kvImageNoFlags))
        
        guard error == kvImageNoError else {
            return error
        }
        
        var backColor: UInt8 = 0
        
        return vImageRotate90_ARGB8888(sourceBuffer,
                                       destinationBuffer,
                                       rotationConstant,
                                       &backColor,
                                       .init(kvImageNoFlags))
}

@discardableResult
func vImageRotate_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ angleInRadians: Float)
    -> vImage_Error {
        
        let error = vImageBuffer_Init(destinationBuffer,
                                      sourceBuffer.pointee.height,
                                      sourceBuffer.pointee.width,
                                      32,
                                      .init(kvImageNoFlags))
        
        guard error == kvImageNoError else {
            return error
        }
        
        var backColor: UInt8 = 0
        
        return vImageRotate_ARGB8888(sourceBuffer,
                                     destinationBuffer,
                                     nil,
                                     angleInRadians,
                                     &backColor,
                                     .init(kvImageNoFlags))
}

@discardableResult
func vImageResize_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ resizeFactor: Float)
    -> vImage_Error {
        
        let error = vImageBuffer_Init(destinationBuffer,
                                      .init(Float(sourceBuffer.pointee.height) / resizeFactor),
                                      .init(Float(sourceBuffer.pointee.width) / resizeFactor),
                                      32,
                                      .init(kvImageNoFlags))
        
        guard error == kvImageNoError else {
            return error
        }
        
        return vImageScale_ARGB8888(sourceBuffer,
                                    destinationBuffer,
                                    nil,
                                    .init(kvImageNoFlags))
}

@discardableResult
func vImageDropAlpha_BGRA8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>)
    -> vImage_Error {
        
        let error = vImageBuffer_Init(destinationBuffer,
                                      sourceBuffer.pointee.height,
                                      sourceBuffer.pointee.width,
                                      32,
                                      .init(kvImageNoFlags))
        
        guard error == kvImageNoError else {
            return error
        }
        
        destinationBuffer.pointee.rowBytes = .init(sourceBuffer.pointee.width * 3)
        
        return vImageConvert_BGRA8888toRGB888(sourceBuffer,
                                              destinationBuffer,
                                              .init(kvImageNoFlags))
}
