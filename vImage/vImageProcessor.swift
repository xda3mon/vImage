//
//  vImageProcessor.swift
//  vImage
//
//  Created by What on 2018/12/28.
//  Copyright © 2018 dumbass. All rights reserved.
//

@_exported import Accelerate.vImage

@discardableResult
public func vImageBuffer_InitWithCVImage(
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
public func vImageFlipHorizontally_ARGB8888(
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
public func vImageFlipVertically_ARGB8888(
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
public func vImageRotate90_ARGB8888(
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
public func vImageRotate_ARGB8888(
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
public func vImageResize_ARGB8888(
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
public func vImageResizeWidth_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ width: vImagePixelCount)
    -> vImage_Error {

        vImageResize_ARGB8888(
            sourceBuffer,
            destinationBuffer,
            Float(sourceBuffer.pointee.width) / Float(width))
}

@discardableResult
public func vImageResizeHeight_ARGB8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ height: vImagePixelCount)
    -> vImage_Error {

        vImageResize_ARGB8888(
            sourceBuffer,
            destinationBuffer,
            Float(sourceBuffer.pointee.height) / Float(height))
}

@discardableResult
public func vImageDropAlpha_BGRA8888(
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

@discardableResult
public func vImageCrop_BGRA8888(
    _ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ roi: CGRect)
    -> vImage_Error {

        let roi = roi.intersection(CGRect(x: 0,
                                          y: 0,
                                          width: Int(sourceBuffer.pointee.width),
                                          height: Int(sourceBuffer.pointee.height)))
        let bytesPerPixel = 4

        let start = sourceBuffer.pointee.rowBytes * .init(roi.minY) + bytesPerPixel * .init(roi.minX)

        defer { destinationBuffer.pointee.rowBytes = sourceBuffer.pointee.rowBytes
            destinationBuffer.pointee.data = sourceBuffer.pointee.data.advanced(by: start)
        }

        return vImageBuffer_Init(destinationBuffer,
                                 .init(roi.height),
                                 .init(roi.width),
                                 32,
                                 .init(kvImageNoFlags))
}
