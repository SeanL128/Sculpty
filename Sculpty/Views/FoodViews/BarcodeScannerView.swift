//
//  BarcodeScannerView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/14/25.
//

import SwiftUI
import Vision

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var log: CaloriesLog
    @Binding var foodAdded: Bool
    
    @Binding var foodToAdd: FatSecretFood?
    @Binding var foodsToAdd: [FatSecretFood]
    
    @StateObject private var coordinator: BarcodeScannerCoordinator = BarcodeScannerCoordinator()
    @StateObject private var api: FatSecretAPI = FatSecretAPI()
    
    @State private var isScanning: Bool = true
    @State private var showingErrorPopup = false
    
    @State private var cameraPermissionDenied: Bool = false
    
    @State private var isBatchMode: Bool = false
    @State private var scannedItems: [FatSecretFood] = []
    @State private var showBatchList: Bool = false
    
    @State private var isCapturingPhoto = false
    
    @State private var stayOnPage: Bool = true
    @State private var stayOnBatch: Bool = true
    
    @State private var successTrigger: Int = 0
    @State private var errorTrigger: Int = 0
    @State private var warningTrigger: Int = 0
    
    @State private var lastScanTime: Date = Date.distantPast
    @State private var cooldownTimer: Timer?
    
    private var checkmarkValid: Bool { isBatchMode && !scannedItems.isEmpty }
    
    init(log: CaloriesLog, foodAdded: Binding<Bool>, foodToAdd: Binding<FatSecretFood?>) {
        self.log = log
        self._foodAdded = foodAdded
        self._foodToAdd = foodToAdd
        self._foodsToAdd = .constant([])
    }
    
    init(
        log: CaloriesLog,
        foodAdded: Binding<Bool>,
        foodToAdd: Binding<FatSecretFood?>,
        foodsToAdd: Binding<[FatSecretFood]>
    ) {
        self.log = log
        self._foodAdded = foodAdded
        self._foodToAdd = foodToAdd
        self._foodsToAdd = foodsToAdd
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                CameraView(coordinator: coordinator)
                    .ignoresSafeArea()
                
                if coordinator.isSessionRunning && !showBatchList {
                    ScannerOverlay()
                }
                
                VStack {
                    HStack(alignment: .center) {
                        Button {
                            if isBatchMode && !scannedItems.isEmpty {
                                warningTrigger += 1
                                
                                Popup.show(content: {
                                    ConfirmationPopup(
                                        selection: $stayOnPage,
                                        promptText: "Unsaved Scanned Items",
                                        resultText: "Are you sure you want to leave without saving scanned items?",
                                        cancelText: "Discared Items",
                                        confirmText: "Stay on Page"
                                    )
                                })
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(.trailing, 6)
                                .font(Font.system(size: 22))
                        }
                        .textColor()
                        .onChange(of: stayOnPage) {
                            if !stayOnPage {
                                dismiss()
                            }
                        }
                        
                        Spacer()
                        
                        if isBatchMode {
                            Button {
                                if checkmarkValid {
                                    foodsToAdd = scannedItems
                                }
                                
                                dismiss()
                            } label: {
                                Image(systemName: "checkmark")
                                    .padding(.trailing, 6)
                                    .font(Font.system(size: 22))
                            }
                            .disabled(!checkmarkValid)
                            .foregroundStyle(checkmarkValid ? ColorManager.text : ColorManager.secondary)
                            .animatedButton(isValid: checkmarkValid)
                            .animation(.easeInOut(duration: 0.2), value: checkmarkValid)
                        }
                    }
                    .padding()
                    .padding(.bottom, 2)
                    .background(ColorManager.background)
                    
                    if coordinator.isSessionRunning {
                        if !showBatchList {
                            VStack(spacing: 8) {
                                if isBatchMode {
                                    Text("Scan multiple barcodes")
                                        .bodyText(size: 16)
                                        .darkModeTextColor()
                                        .multilineTextAlignment(.center)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .top)),
                                            removal: .opacity.combined(with: .move(edge: .bottom))
                                        ))
                                } else {
                                    Text("Position barcode in the frame")
                                        .bodyText(size: 16)
                                        .darkModeTextColor()
                                        .multilineTextAlignment(.center)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .top)),
                                            removal: .opacity.combined(with: .move(edge: .bottom))
                                        ))
                                }
                                
                                if api.isLoading {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(ColorManager.text.dark)
                                        
                                        Text("Looking up product...")
                                            .bodyText(size: 14)
                                            .darkModeTextColor()
                                    }
                                    .padding(.top, 4)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                        removal: .opacity.combined(with: .scale(scale: 0.8))
                                    ))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 30)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            
                            if isBatchMode {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showBatchList = true
                                    }
                                    
                                    Popup.show(content: {
                                        BatchListPopup(items: scannedItems, onRemove: { index in
                                            scannedItems.remove(at: index)
                                        })
                                    }, onDismiss: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showBatchList = false
                                        }
                                    })
                                } label: {
                                    HStack(alignment: .center) {
                                        Text("\(scannedItems.count) items")
                                            .bodyText(size: 18)
                                            .monospacedDigit()
                                            .contentTransition(.numericText())
                                        
                                        Image(systemName: "chevron.right")
                                            .padding(.leading, -2)
                                            .font(Font.system(size: 12))
                                    }
                                }
                                .secondaryColor()
                                .animatedButton()
                                .animation(.easeOut(duration: 0.3), value: scannedItems.count)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            if coordinator.isTorchAvailable {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        coordinator.toggleTorch()
                                    }
                                } label: {
                                    Image(systemName: coordinator.isTorchOn ? "flashlight.on.circle.fill" : "flashlight.off.circle") // swiftlint:disable:this line_length
                                        .font(.system(size: 30))
                                }
                                .textColor()
                                .animatedButton(feedback: .impact(weight: .light))
                            } else {
                                Image(systemName: "flashlight.slash.circle")
                                    .font(.system(size: 30))
                                    .textColor()
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    coordinator.capturePhoto()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if isCapturingPhoto {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                            .tint(ColorManager.text)
                                            .transition(.opacity)
                                    } else {
                                        Image(systemName: "camera.circle.fill")
                                            .font(.system(size: 30))
                                            .transition(.opacity)
                                    }
                                }
                            }
                            .textColor()
                            .disabled(isCapturingPhoto)
                            .animatedButton(feedback: .impact(weight: .light), isValid: !isCapturingPhoto)
                            
                            Spacer()
                            
                            Button {
                                if isBatchMode {
                                    if !scannedItems.isEmpty {
                                        warningTrigger += 1
                                        
                                        Popup.show(content: {
                                            ConfirmationPopup(
                                                selection: $stayOnBatch,
                                                promptText: "Unsaved Scanned Items",
                                                resultText: "Are you sure you want to turn off batch mode and clear scanned items?", // swiftlint:disable:this line_length
                                                cancelText: "Clear Items",
                                                confirmText: "Keep Items"
                                            )
                                        })
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isBatchMode = false
                                        }
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isBatchMode = true
                                    }
                                }
                            } label: {
                                Image(systemName: isBatchMode ? "list.bullet.circle.fill" : "list.bullet.circle")
                                    .font(.system(size: 30))
                            }
                            .textColor()
                            .animatedButton(feedback: .selection)
                            .onChange(of: stayOnBatch) {
                                if !stayOnBatch {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isBatchMode = false
                                    }
                                    
                                    scannedItems.removeAll()
                                    showBatchList = false
                                    cooldownTimer?.invalidate()
                                    lastScanTime = Date.distantPast
                                    
                                    stayOnBatch = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(ColorManager.background)
                }
                
                if cameraPermissionDenied {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .secondaryColor()
                        
                        Text("Camera Access Required")
                            .bodyText(size: 24, weight: .bold)
                            .textColor()
                        
                        Text("To scan barcodes, Sculpty needs access to your camera. Please enable camera access in Settings.") // swiftlint:disable:this line_length
                            .bodyText(size: 16)
                            .secondaryColor()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 12)
                        
                        Button {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        } label: {
                            Text("Open Settings")
                                .bodyText(size: 24, weight: .bold)
                        }
                        .textColor()
                        .animatedButton(scale: 0.98)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .bodyText(size: 16)
                        }
                        .textColor()
                        .animatedButton(scale: 0.98)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ColorManager.background)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                coordinator.onBarcodeDetected = handleBarcodeDetected
                coordinator.onPhotoCaptured = handlePhotoCaptured
                coordinator.requestCameraPermission { granted in
                    cameraPermissionDenied = !granted
                    
                    if granted {
                        coordinator.startScanning()
                    }
                }
            }
            .onDisappear {
                coordinator.stopScanning()
                coordinator.cleanup()
                
                coordinator.onBarcodeDetected = nil
                coordinator.onPhotoCaptured = nil
                
                cooldownTimer?.invalidate()
            }
            .onChange(of: foodAdded) {
                if foodAdded {
                    dismiss()
                }
            }
            .sensoryFeedback(.success, trigger: successTrigger)
            .sensoryFeedback(.error, trigger: errorTrigger)
            .sensoryFeedback(.warning, trigger: warningTrigger)
        }
    }
    
    private func handleBarcodeDetected(_ barcode: String) {
        guard isScanning && !showBatchList && !showingErrorPopup else { return }
        
        if isBatchMode {
            let now = Date()
            let timeSinceLastScan = now.timeIntervalSince(lastScanTime)
            
            if timeSinceLastScan < 1.0 {
                return
            }
            
            lastScanTime = now
            startCooldownTimer()
        } else {
            isScanning = false
        }
        
        Task {
            await lookupBarcode(barcode)
        }
    }
    
    private func startCooldownTimer() {
        cooldownTimer?.invalidate()
        
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()
            let timeSinceLastScan = now.timeIntervalSince(lastScanTime)
            
            if timeSinceLastScan >= 1.0 {
                cooldownTimer?.invalidate()
                cooldownTimer = nil
            }
        }
    }
    
    private func handlePhotoCaptured(_ image: UIImage) {
        isCapturingPhoto = true
        
        guard let cgImage = image.cgImage else {
            isCapturingPhoto = false
            
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            DispatchQueue.main.async {
                self.isCapturingPhoto = false
                
                if error != nil {
                    self.errorTrigger += 1
                    
                    Popup.show(content: {
                        InfoPopup(title: "Error", text: "Failed to process captured image.")
                    })
                    
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation],
                      let firstBarcode = results.first,
                      let barcodeString = firstBarcode.payloadStringValue else {
                    self.errorTrigger += 1
                    
                    Popup.show(content: {
                        InfoPopup(
                            title: "Error",
                            text: "No barcode found in captured image. Try getting closer and ensure the barcode is clearly visible." // swiftlint:disable:this line_length
                        )
                    })
                    
                    return
                }
                
                self.handleBarcodeDetected(barcodeString)
            }
        }
        
        request.symbologies = [.ean13, .ean8, .upce, .qr]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isCapturingPhoto = false
                    
                    self.errorTrigger += 1
                    
                    Popup.show(content: {
                        InfoPopup(title: "Error", text: "Failed to process captured image.")
                    })
                }
            }
        }
    }
    
    @MainActor
    private func lookupBarcode(_ barcode: String) async {
        api.isLoading = true
        api.loaded = false
        
        do {
            let food = try await api.lookupBarcode(barcode)
            
            if isBatchMode {
                if !scannedItems.contains(where: { $0.food_id == food.food_id }) {
                    successTrigger += 1
                    
                    scannedItems.append(food)
                }
            } else {
                successTrigger += 1
                
                foodToAdd = food
                
                dismiss()
            }
        } catch {
            errorTrigger += 1
            
            if isBatchMode {
                showingErrorPopup = true
            } else {
                isScanning = false
            }
            
            Popup.show(content: {
                InfoPopup(
                    title: "Error",
                    text: "Could not find nutrition information for this barcode. Please try again or search manually."
                )
            }, onDismiss: { showingErrorPopup = false })
        }
        
        api.isLoading = false
        api.loaded = true
    }
}
