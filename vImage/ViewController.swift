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
        
        capture = try! .init(preview: view)
        
        capture.didOutputSampleBuffer = { _, sampleBuffer, _ in
            
            var buffer = vImage_Buffer()
            var flippedBuffer = vImage_Buffer()
            var rotatedBuffer = vImage_Buffer()
            var resizedBuffer = vImage_Buffer()
            var bgrBuffer = vImage_Buffer()
            
            defer {
                free(buffer.data)
                free(flippedBuffer.data)
                free(rotatedBuffer.data)
                free(resizedBuffer.data)
                free(bgrBuffer.data)
            }
            
            flip(.horizontal, &flippedBuffer)
            >>> rotate90(1, &rotatedBuffer)
            >>> resize(3, &resizedBuffer)
            >>> dropAlpha(&bgrBuffer)
            >>> create(&buffer, CMSampleBufferGetImageBuffer(sampleBuffer)!)
        }
        
        capture.start()
    }
}
