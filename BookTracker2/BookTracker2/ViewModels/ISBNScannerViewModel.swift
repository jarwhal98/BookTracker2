//
//  ISBNScannerViewModel.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import AVFoundation
import Foundation

class ISBNScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedISBN: String?
    @Published var isScanning = false
    @Published var error: String?
    @Published var showingPermissionAlert = false
    @Published var cameraPermissionGranted = false
    
    let captureSession = AVCaptureSession()
    private var isSessionConfigured = false
    
    override init() {
        super.init()
        print("ISBNScannerViewModel initialized")
    }
    
    func setupCaptureSession() {
        guard !isSessionConfigured else {
            print("Session already configured")
            startScanning()
            return
        }
        
        print("Setting up capture session...")
        captureSession.beginConfiguration()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video device available")
            error = "No video device available"
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                print("Added video input")
            } else {
                print("Could not add video input")
                error = "Could not add video input"
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean13]
                print("Added metadata output")
            } else {
                print("Could not add metadata output")
                error = "Could not add metadata output"
                return
            }
            
            captureSession.commitConfiguration()
            isSessionConfigured = true
            print("Capture session setup complete")
            startScanning()
            
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
            self.error = "Error setting up camera: \(error.localizedDescription)"
            return
        }
    }
    
    func startScanning() {
        guard isSessionConfigured else {
            print("Cannot start scanning - session not configured")
            return
        }
        
        if !captureSession.isRunning {
            print("Starting capture session...")
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
                DispatchQueue.main.async {
                    self?.isScanning = true
                    print("Capture session is now running")
                }
            }
        } else {
            print("Capture session already running")
        }
    }
    
    func stopScanning() {
        guard isScanning else { return }
        
        print("Stopping scanner...")
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self?.isScanning = false
                    print("Scanner stopped")
                }
            }
        }
    }
    
    func checkAndRequestCameraPermission() {
        print("Checking camera permission status...")
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("Current camera permission status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Camera already authorized")
            cameraPermissionGranted = true
            setupCaptureSession()
        case .notDetermined:
            print("Camera permission not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    print("Camera permission response: \(granted)")
                    self?.cameraPermissionGranted = granted
                    if granted {
                        self?.setupCaptureSession()
                    } else {
                        self?.error = "Camera access is required to scan ISBN barcodes"
                        self?.showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            print("Camera permission denied or restricted")
            error = "Camera access is required to scan ISBN barcodes"
            showingPermissionAlert = true
        @unknown default:
            print("Unknown camera permission status")
            error = "Unexpected camera authorization status"
            showingPermissionAlert = true
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue,
           metadataObject.type == .ean13 {
            print("Barcode detected: \(stringValue)")
            scannedISBN = stringValue
            stopScanning()
        }
    }
} 