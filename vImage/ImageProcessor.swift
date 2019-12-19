//
//  ImageProcessor.swift
//  vImage
//
//  Created by What on 2018/12/28.
//  Copyright © 2018 dumbass. All rights reserved.
//

import Accelerate.vImage

public typealias vImageBuffer = UnsafeMutablePointer<vImage_Buffer>
public typealias ImageProcessor =  (vImageBuffer) -> (vImageBuffer)

precedencegroup ImageProcessorPrecedence {
    associativity: left
}

infix operator >>> : ImageProcessorPrecedence

@discardableResult
public func >>> (processor: ImageProcessor, buffer: vImageBuffer) -> vImageBuffer {
    return processor(buffer)
}

@discardableResult
public func >>> (buffer: vImageBuffer, processor: ImageProcessor) -> vImageBuffer {
    return processor(buffer)
}

@discardableResult
public func >>> (processor0: @escaping ImageProcessor, processor1: @escaping ImageProcessor) -> ImageProcessor {
    return { processor1(processor0($0)) }
}

public enum vImage_Direction {
    case horizontal
    case vertical
}

public enum vImage_Resize {
    case custom(Float)
    case width(vImagePixelCount)
    case height(vImagePixelCount)
}

///// create ARGB8888 buffer from CVImageBuffer
///
/// - Parameters:
///   - buffer: You are responsible for releasing it when you are done with it
///   - imageBuffer: source imageBuffer
/// - Returns: vImageBuffer
public func create(_ imageBuffer: CVImageBuffer, _ buffer: vImageBuffer) -> vImageBuffer {
    vImageBuffer_InitWithCVImage(buffer, imageBuffer)
    return buffer
}

/// flip image for ARGB8888 buffer
///
/// - Parameters:
///   - dir: horizontal or vertical
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
public func flip(_ dir: vImage_Direction, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        switch dir {
        case .horizontal: vImageFlipHorizontally_ARGB8888(sourceBuffer, buffer)
        case .vertical: vImageFlipVertically_ARGB8888(sourceBuffer, buffer)
        }
        return buffer
    }
}

/// rotate image anticlockwise for ARGB8888 buffer
///
/// - Parameters:
///   - rotation: 1, 2, 3 means 90, 180, 270 degree
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
public func rotate90(_ rotationConstant: UInt8, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageRotate90_ARGB8888(sourceBuffer, buffer, rotationConstant)
        return buffer
    }
}

public func rotate(_ angleInRadians: Float, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageRotate_ARGB8888(sourceBuffer, buffer, angleInRadians)
        return buffer
    }
}

/// resize image size for ARGB8888 buffer
///
/// - Parameters:
///   - resize: resize factor, see vImage_Resize
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
public func resize(_ resize: vImage_Resize, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        switch resize {
        case .custom(let factor): vImageResize_ARGB8888(sourceBuffer, buffer, factor)
        case .width(let width): vImageResizeWidth_ARGB8888(sourceBuffer, buffer, width)
        case .height(let height): vImageResizeHeight_ARGB8888(sourceBuffer, buffer, height)
        }
        return buffer
    }
}

/// drop alpha channel for ARGB888 buffer
///
/// - Parameters:
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
public func dropAlpha(_ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageDropAlpha_BGRA8888(sourceBuffer, buffer)
        return buffer
    }
}

/// crop image for ARGB888 buffer
///
/// - Parameters:
///   - roi: Region of interest
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
public func crop(_ roi: CGRect, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageCrop_BGRA8888(sourceBuffer, buffer, roi)
        return buffer
    }
}
