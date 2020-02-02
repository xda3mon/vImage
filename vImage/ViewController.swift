//
//  ViewController.swift
//  vImage
//
//  Created by What on 2018/12/16.
//  Copyright © 2018 dumbass. All rights reserved.
//

import UIKit
import Accelerate
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var capture: VideoCapture!

    override func viewDidLoad() {
        super.viewDidLoad()

        let sourceImage = #imageLiteral(resourceName: "lena").cgImage!
        
        var sourceBuffer = vImage_Buffer()
        var destinationBuffer = vImage_Buffer()
        
        defer {
            free(sourceBuffer.data)
//            free(destinationBuffer.data)
        }
        
        var format = vImage_CGImageFormat(bitsPerComponent: UInt32(sourceImage.bitsPerComponent),
                                          bitsPerPixel: UInt32(sourceImage.bitsPerPixel),
                                          colorSpace: .passUnretained(sourceImage.colorSpace!),
                                          bitmapInfo: sourceImage.bitmapInfo,
                                          version: 0,
                                          decode: sourceImage.decode,
                                          renderingIntent: sourceImage.renderingIntent)
        
        vImageBuffer_InitWithCGImage(&sourceBuffer,
                                     &format,
                                     nil,
                                     sourceImage,
                                     .init(kvImageNoFlags))

//        crop(CGRect(x: 0, y: 100, width: sourceImage.width, height: 200), &destinationBuffer) >>> &sourceBuffer
        
        sourceBuffer.desaturate_ARGB8888(regionOfInterest: .init(x: 100, y: 100, width: 100, height: 100))
        var error = kvImageNoError
        vImageCreateCGImageFromBuffer(&sourceBuffer,
                                      &format,
                                      nil,
                                      nil,
                                      .init(kvImageNoFlags),
                                      &error)
            .flatMap { $0.takeUnretainedValue() }
            .flatMap { imageView.image = .init(cgImage: $0) }
        print(vImage.Error.init(rawValue: error))
        return;

        capture = try! .init(preview: view)

        capture.didOutputSampleBuffer = { _, sampleBuffer, _ in

            var buffer = vImage_Buffer()
            var flippedBuffer = vImage_Buffer()
            var rotatedBuffer = vImage_Buffer()
            var resizedBuffer = vImage_Buffer()
            var bgrBuffer = vImage_Buffer()
            var croppedBuffer = vImage_Buffer()

            defer {
                free(buffer.data)
                free(flippedBuffer.data)
                free(rotatedBuffer.data)
                free(resizedBuffer.data)
                free(bgrBuffer.data)
                free(croppedBuffer.data)
            }

//            flip(.horizontal, &flippedBuffer)
//                >>> rotate90(1, &rotatedBuffer)
//                >>> resize(.custom(3), &resizedBuffer)
//                >>> dropAlpha(&bgrBuffer)
            crop(CGRect(x: 0, y: 0, width: 1080, height: 1080), &croppedBuffer)
                >>> create(CMSampleBufferGetImageBuffer(sampleBuffer)!, &buffer)
//

//            vImage_CGImageFormat(bitsPerComponent: 8,
//                                 bitsPerPixel: 32,
//                                 colorSpace: CGColorSpaceCreateDeviceRGB(),
//                                 bitmapInfo: CGBitmapInfo.byteOrder32Little,
//                                 renderingIntent: .defaultIntent)

            var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                 bitsPerPixel: 32,
                                 colorSpace: .passUnretained(CGColorSpaceCreateDeviceRGB()),
                                 bitmapInfo: .byteOrder32Little,
                                 version: 0,
                                 decode: nil,
                                 renderingIntent: .defaultIntent)

            if #available(iOS 13.0, *) {
//                let image = try? croppedBuffer.createCGImage(format: format)

                let image = vImageCreateCGImageFromBuffer(&croppedBuffer,
                                                          &format,
                                                          nil,
                                                          nil,
                                                          vImage_Flags(kvImageNoFlags),
                                                          nil)!
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: image.takeUnretainedValue())
                }
            } else {
                // Fallback on earlier versions
            }
        }

        capture.start()
    }
}
