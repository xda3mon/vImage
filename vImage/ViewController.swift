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
import BellMouth

class ViewController: UIViewController {
 
    @IBOutlet weak var imageView: UIImageView!
    
    var capture: ScannerCapture!
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capture = try! ScannerCapture(preview: view)
        capture.didOutputSampleBuffer = { [unowned self] _, sampleBuffer, _ in
            
            var destinationBuffer = vImage_Buffer()
            defer { free(destinationBuffer.data) }
            vImageConvert_sampleBufferToPlanar8(sampleBuffer, &destinationBuffer)
            let buffer = destinationBuffer.data.assumingMemoryBound(to: UInt8.self)
//            print(buffer.pointee)
            self.image = vImageCreateCGImageFromBuffer(&destinationBuffer)
            detect(buffer)
//            print(buffer.pointee)

            DispatchQueue.main.async {
                self.imageView.image = self.image
            }
        }
        
        capture.start()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
}

func detect(_ buffer: UnsafeMutablePointer<UInt8>) {

    var input = FaceDetectInput(image_buffer: buffer,
                                width: 500, height: 500,
                                color_type: BGRA,
                                desired_bbox: .init(x: 0, y: 0, width: 500, height: 500),
                                min_coselection_rate: 0.7)
    
    var output = FaceDetectOutput(has_face: 0,
                                  in_bbox: 0,
                                  real_bbox: .init())
    
    let result = DetectFace(&input, &output)
    
    print(result, output)
    
}
