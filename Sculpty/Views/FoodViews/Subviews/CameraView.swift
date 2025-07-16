//
//  CameraView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct CameraView: UIViewRepresentable {
    @ObservedObject var coordinator: BarcodeScannerCoordinator
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        
        view.backgroundColor = UIColor(ColorManager.background)
        
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        if coordinator.isSessionRunning {
            uiView.setupPreviewLayer(with: coordinator.session)
        }
    }
}
