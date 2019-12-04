//
//  Processor.swift
//  vImage
//
//  Created by What on 2018/12/28.
//  Copyright © 2018 dumbass. All rights reserved.
//

import Accelerate.vImage

typealias vImageBuffer = UnsafeMutablePointer<vImage_Buffer>
typealias ImageProcessor =  (vImageBuffer) -> (vImageBuffer)

precedencegroup ImageProcessorPrecedence {
    associativity: left
}

infix operator >>> : ImageProcessorPrecedence

@discardableResult
func >>> (processor: ImageProcessor, buffer: vImageBuffer) -> vImageBuffer {
    return processor(buffer)
}

@discardableResult
func >>> (buffer: vImageBuffer, processor: ImageProcessor) -> vImageBuffer {
    return processor(buffer)
}

@discardableResult
func >>> (processor0: @escaping ImageProcessor, processor1: @escaping ImageProcessor) -> ImageProcessor {
    return { processor1(processor0($0)) }
}

enum vImage_Direction {
    case horizontal
    case vertical
}

/// create ARGB8888 buffer from CVImageBuffer
///
/// - Parameters:
///   - buffer: You are responsible for releasing it when you are done with it
///   - imageBuffer: source imageBuffer
/// - Returns: vImageBuffer
func create(_ buffer: vImageBuffer, _ imageBuffer: CVImageBuffer) -> vImageBuffer {
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
func flip(_ dir: vImage_Direction, _ buffer: vImageBuffer) -> ImageProcessor {
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
func rotate90(_ rotationConstant: UInt8, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageRotate90_ARGB8888(sourceBuffer, buffer, rotationConstant)
        return buffer
    }
}

func rotate(_ angleInRadians: Float, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageRotate_ARGB8888(sourceBuffer, buffer, angleInRadians)
        return buffer
    }
}

/// resize image size for ARGB8888 buffer
///
/// - Parameters:
///   - factor: resize factor, typecally it always greater than or equal 1.0
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
func resize(_ factor: Float, _ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageResize_ARGB8888(sourceBuffer, buffer, factor)
        return buffer
    }
}

/// drop alpha channel for ARGB888 buffer
///
/// - Parameters:
///   - buffer: You are responsible for releasing it when you are done with it
///     and it will be the return value of ImageProcessor
/// - Returns: ImageProcessor
func dropAlpha(_ buffer: vImageBuffer) -> ImageProcessor {
    return { sourceBuffer in
        vImageDropAlpha_BGRA8888(sourceBuffer, buffer)
        return buffer
    }
}
