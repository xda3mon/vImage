import CoreMedia.CMSampleBuffer
import Accelerate.vImage
import UIKit.UIImage

struct vImage_Config {
    
    static let `default`: vImage_Config = .init()
    
    var redCoefficient: Float
    var greenCoefficient: Float
    var blueCoefficient: Float
    var divisor: Int32
    var compress: UInt8
    var format: vImage_CGImageFormat
    
    var coefficientsMatrix: [Int16] {
        return [
            Int16(redCoefficient * .init(divisor)),
            Int16(greenCoefficient * .init(divisor)),
            Int16(blueCoefficient * .init(divisor))
        ]
    }
    
    init(redCoefficient: Float, greenCoefficient: Float, blueCoefficient: Float, divisor: Int32, compress: UInt8, format: vImage_CGImageFormat) {
        
        self.redCoefficient         = redCoefficient
        self.blueCoefficient        = blueCoefficient
        self.greenCoefficient       = greenCoefficient
        self.divisor                = divisor
        self.compress               = compress
        self.format                 = format
    }
    
    init() {
        
        let format = vImage_CGImageFormat(bitsPerComponent: 8,
                                          bitsPerPixel: 32,
                                          colorSpace: .passRetained(CGColorSpaceCreateDeviceRGB()),
                                          bitmapInfo: .init(rawValue: 5),
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: .defaultIntent)
        
        self.init(redCoefficient: 0.333,
                  greenCoefficient: 0.334,
                  blueCoefficient: 0.333,
                  divisor: 0x1000,
                  compress: 1,
                  format: format)
        
//        self.init(redCoefficient: 0.2126,
//                  greenCoefficient: 0.7152,
//                  blueCoefficient: 0.0722,
//                  divisor: 0x1000,
//                  compress: 1,
//                  format: format)
    }
}

@discardableResult
func vImageConvert_sampleBufferToPlanar8(
    _ sampleBuffer: CMSampleBuffer,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ config: vImage_Config = .default)
    -> vImage_Error {
        
        var preBias: Int16 = 0
        let postBias: Int32 = 0
        let divisor: Int32 = config.divisor
        var coefficientsMatrix: [Int16] = config.coefficientsMatrix
        var format: vImage_CGImageFormat = config.format
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return kvImageInvalidImageObject
        }
        
        var sourceBuffer: vImage_Buffer = {
            
            var sourceImageBuffer = vImage_Buffer()
            var scaledBuffer = vImage_Buffer()
            
            vImageBuffer_InitWithCVPixelBuffer(
                &sourceImageBuffer,
                &format,
                imageBuffer,
                nil,
                nil,
                vImage_Flags(kvImageNoFlags))
            
            
            vImageBuffer_Init(&scaledBuffer,
                              sourceImageBuffer.height / UInt(config.compress),
                              sourceImageBuffer.width / UInt(config.compress),
                              format.bitsPerPixel,
                              vImage_Flags(kvImageNoFlags))
            
            vImageScale_ARGB8888(&sourceImageBuffer,
                                 &scaledBuffer,
                                 nil,
                                 vImage_Flags(kvImageNoFlags))
            
            free(sourceImageBuffer.data)
            
            return scaledBuffer
        }()
        
        defer {
            free(sourceBuffer.data)
        }
        
        vImageBuffer_Init(destinationBuffer,
                          sourceBuffer.height,
                          sourceBuffer.width,
                          8,
                          vImage_Flags(kvImageNoFlags))
        
        return vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                                                      destinationBuffer,
                                                      &coefficientsMatrix,
                                                      divisor,
                                                      &preBias,
                                                      postBias,
                                                      vImage_Flags(kvImageNoFlags))
}

func vImageCreateCGImageFromBuffer(_ sourceBuffer: UnsafeMutablePointer<vImage_Buffer>) -> UIImage? {
    
    var monoFormat = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8,
        colorSpace: Unmanaged.passRetained(CGColorSpaceCreateDeviceGray()),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
        version: 0,
        decode: nil,
        renderingIntent: .defaultIntent)
    
    return vImageCreateCGImageFromBuffer(
        sourceBuffer,
        &monoFormat,
        nil,
        nil,
        vImage_Flags(kvImageNoFlags),
        nil)
        .flatMap { $0.takeRetainedValue() }
        .flatMap(UIImage.init)
}

@discardableResult
func vImageConvert_ImageToPlanar8(
    _ cgImage: CGImage,
    _ destinationBuffer: UnsafeMutablePointer<vImage_Buffer>,
    _ config: vImage_Config = .default)
    -> vImage_Error {
    
        guard let colorSpace = cgImage.colorSpace else {
            return kvImageInvalidImageObject
        }
        
        var preBias: Int16 = 0
        let postBias: Int32 = 0
        let divisor: Int32 = config.divisor
        var coefficientsMatrix: [Int16] = config.coefficientsMatrix
        
        var format: vImage_CGImageFormat = {
            return vImage_CGImageFormat(
                bitsPerComponent: UInt32(cgImage.bitsPerComponent),
                bitsPerPixel: UInt32(cgImage.bitsPerPixel),
                colorSpace: .passRetained(colorSpace),
                bitmapInfo: cgImage.bitmapInfo,
                version: 0,
                decode: nil,
                renderingIntent: cgImage.renderingIntent)
        }()
        
        
        var sourceBuffer: vImage_Buffer = {
            var sourceImageBuffer = vImage_Buffer()
            
            vImageBuffer_InitWithCGImage(&sourceImageBuffer,
                                         &format,
                                         nil,
                                         cgImage,
                                         vImage_Flags(kvImageNoFlags))
            
            return sourceImageBuffer
        }()
        
        defer {
            free(sourceBuffer.data)
        }
        
        vImageBuffer_Init(destinationBuffer,
                          sourceBuffer.height,
                          sourceBuffer.width,
                          8,
                          vImage_Flags(kvImageNoFlags))
        
        return vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                                               destinationBuffer,
                                               &coefficientsMatrix,
                                               divisor,
                                               &preBias,
                                               postBias,
                                               vImage_Flags(kvImageNoFlags))
    
}
