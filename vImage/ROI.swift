//
//  ROI.swift
//  vImage
//
//  Created by What on 2020/2/2.
//  Copyright © 2020 dumbass. All rights reserved.
//

import Accelerate.vImage

public extension vImage_Buffer {
    
    func desaturate_ARGB8888(regionOfInterest roi: CGRect) {
        
        guard Int(roi.maxX) <= width && Int(roi.maxY) <= height && Int(roi.minX) >= 0 && Int(roi.minY) >= 0 else {
                return print("ROI is out of bounds.")
        }
        
        let bytesPerPixel = 4
        
        let start = Int(roi.origin.y) * rowBytes + Int(roi.origin.x) * bytesPerPixel
        
        var desaturationBuffer = vImage_Buffer(data: data.advanced(by: start),
                                               height: vImagePixelCount(roi.height),
                                               width: vImagePixelCount(roi.width),
                                               rowBytes: rowBytes)
        
        let divisor: Int32 = 0x1000
        
        let desaturationMatrix = [
            0.0722, 0.0722, 0.0722, 0,
            0.7152, 0.7152, 0.7152, 0,
            0.2126, 0.2126, 0.2126, 0,
            0,      0,      0,      1
            ].map {
                return Int16($0 * Float(divisor))
        }
        
        let error = vImageMatrixMultiply_ARGB8888(&desaturationBuffer,
                                                  &desaturationBuffer,
                                                  desaturationMatrix,
                                                  divisor,
                                                  nil, nil,
                                                  vImage_Flags(kvImageNoFlags))
        
        if error != kvImageNoError {
            print("Error: \(error)")
        }
    }

}
