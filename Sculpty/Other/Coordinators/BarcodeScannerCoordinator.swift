//
//  BarcodeScannerCoordinator.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import SwiftUI
import AVFoundation
import Vision

class BarcodeScannerCoordinator: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate { // swiftlint:disable:this line_length
    var onBarcodeDetected: ((String) -> Void)?
    
    @Published var isSessionRunning = false
    @Published var isTorchOn = false
    @Published var isTorchAvailable = false
    
    private var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    private var photoOutput: AVCapturePhotoOutput?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var lastBarcodeDetectionTime: Date = Date.distantPast
    private let barcodeDetectionInterval: TimeInterval = 0.5
    
    var session: AVCaptureSession? {
        return captureSession
    }
    
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    func startScanning() {
        sessionQueue.async { [weak self] in
            self?.setupCaptureSession()
        }
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }
    
    func toggleTorch() {
        guard let device = videoDevice, device.hasTorch else { return }
        
        sessionQueue.async { [weak self] in
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .on {
                    device.torchMode = .off
                    
                    DispatchQueue.main.async {
                        self?.isTorchOn = false
                    }
                } else {
                    try device.setTorchModeOn(level: 1.0)
                    
                    DispatchQueue.main.async {
                        self?.isTorchOn = true
                    }
                }
                
                device.unlockForConfiguration()
            } catch {
                debugLog("Error toggling torch: \(error)")
            }
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func setupCaptureSession() {
        guard captureSession == nil else {
            captureSession?.startRunning()
            
            DispatchQueue.main.async { [weak self] in
                self?.isSessionRunning = true
            }
            
            return
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(videoInput) else {
            return
        }
        
        videoDevice = device
        session.addInput(videoInput)
        
        DispatchQueue.main.async { [weak self] in
            self?.isTorchAvailable = device.hasTorch
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.processing"))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        let photoOut = AVCapturePhotoOutput()
        if session.canAddOutput(photoOut) {
            session.addOutput(photoOut)
            photoOutput = photoOut
        }
        
        session.commitConfiguration()
        captureSession = session
        session.startRunning()
        
        DispatchQueue.main.async { [weak self] in
            self?.isSessionRunning = true
        }
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = Date()
        guard now.timeIntervalSince(lastBarcodeDetectionTime) >= barcodeDetectionInterval else { return }
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { [weak self] request, _ in
            guard let results = request.results as? [VNBarcodeObservation],
                  let firstBarcode = results.first,
                  let barcodeString = firstBarcode.payloadStringValue else {
                return
            }
            
            self?.lastBarcodeDetectionTime = Date()
            
            DispatchQueue.main.async {
                self?.onBarcodeDetected?(barcodeString)
            }
        }
        
        request.regionOfInterest = CGRect(
            x: 0.2,
            y: 0.3,
            width: 0.7,
            height: 0.4
        )
        
        request.symbologies = [.ean13, .ean8, .upce, .qr]
        
        let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .up, options: [:])
        try? handler.perform([request])
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onPhotoCaptured?(image)
        }
    }
    
    func cleanup() {
        captureSession?.stopRunning()
        
        if let session = captureSession {
            session.beginConfiguration()
            
            for input in session.inputs {
                session.removeInput(input)
            }
            
            for output in session.outputs {
                session.removeOutput(output)
            }
            
            session.commitConfiguration()
        }
        
        captureSession = nil
        videoDevice = nil
        photoOutput = nil
    }
}
