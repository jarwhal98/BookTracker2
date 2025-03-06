//
//  ISBNScannerView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    func makeUIView(context: Context) -> PreviewView {
        print("Creating camera preview view")
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        print("Camera preview layer configured")
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        print("Updating camera preview view")
        uiView.previewLayer.frame = uiView.bounds
    }
}

struct ISBNScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ISBNScannerViewModel
    var onScan: (String) -> Void  // Add callback for when ISBN is scanned
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if viewModel.cameraPermissionGranted && viewModel.isScanning {
                CameraPreview(session: viewModel.captureSession)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Scanning overlay
            VStack {
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.7))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Scan frame
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 100)
                    
                    Text("Position barcode within frame")
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.7))
                        .cornerRadius(8)
                        .offset(y: 80)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.stopScanning()
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Camera Access Required", isPresented: $viewModel.showingPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(viewModel.error ?? "Please enable camera access in Settings to scan ISBN barcodes.")
        }
        .onAppear {
            print("ISBNScannerView appeared")
            viewModel.checkAndRequestCameraPermission()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .onChange(of: viewModel.scannedISBN) { oldValue, newValue in
            if let isbn = newValue {
                print("ISBN scanned: \(isbn)")
                onScan(isbn)  // Call the callback with the scanned ISBN
                dismiss()
            }
        }
    }
} 