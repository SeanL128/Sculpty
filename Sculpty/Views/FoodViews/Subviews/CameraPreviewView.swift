//
//  CameraPreviewView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import SwiftUI
import AVFoundation

class CameraPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupPreviewLayer(with session: AVCaptureSession?) {
        guard let session = session,
              previewLayer?.session !== session else {
            return
        }
        
        previewLayer?.removeFromSuperlayer()
        
        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        newPreviewLayer.frame = bounds
        newPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        layer.addSublayer(newPreviewLayer)
        previewLayer = newPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewLayer?.frame = bounds
    }
}
