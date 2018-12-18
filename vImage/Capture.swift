//
//  AVCaptureService.swift
//  Scanner
//
//  Created by What on 23/08/2017.
//  Copyright © 2017 What. All rights reserved.
//

import AVFoundation
import UIKit

class ScannerCapture:
    NSObject,
    AVCapturePhotoCaptureDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate {
    
    init(preview: UIView) throws {
        if let device = AVCaptureDevice.default(for: .video) {
            self.device = device
        } else {
            fatalError()
        }
//        let discoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
//
//
//        let input = try AVCaptureDeviceInput(device: discoverySession.devices[0])
//
        let input = try AVCaptureDeviceInput(device: device)
        
        session.addInput(input)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspect
        preview.layer.insertSublayer(previewLayer, at: 0)
        
        super.init()
        
        self.session.sessionPreset = .hd1280x720
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Scanner.videoOutput.queue"))
        
        if self.session.canAddOutput(videoOutput) {
            self.session.addOutput(videoOutput)
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        didOutputSampleBuffer?(output, sampleBuffer, connection)
    }
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    var didOutputSampleBuffer: ((AVCaptureOutput , CMSampleBuffer, AVCaptureConnection) -> Void)?
    let session = AVCaptureSession()
    let previewLayer: AVCaptureVideoPreviewLayer
    let device: AVCaptureDevice
}

