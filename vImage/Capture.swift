//
//  AVCaptureService.swift
//  Scanner
//
//  Created by What on 23/08/2017.
//  Copyright © 2017 What. All rights reserved.
//

import AVFoundation
import UIKit

class VideoCapture: NSObject,
    AVCapturePhotoCaptureDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate {

    init(preview: UIView) throws {

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back)
        let input = try AVCaptureDeviceInput(device: discoverySession.devices[0])

        session.addInput(input)

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspect
        preview.layer.insertSublayer(previewLayer, at: 0)

        super.init()

        session.beginConfiguration()

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Scanner.videoOutput.queue"))

        if self.session.canAddOutput(videoOutput) {
            self.session.addOutput(videoOutput)
        }

        videoOutput.connections.first?.videoOrientation = .portrait

        session.commitConfiguration()
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

    var didOutputSampleBuffer: ((AVCaptureOutput, CMSampleBuffer, AVCaptureConnection) -> Void)?
    let session = AVCaptureSession()
    let previewLayer: AVCaptureVideoPreviewLayer
}
