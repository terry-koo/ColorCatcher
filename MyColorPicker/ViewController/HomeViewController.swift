//
//  ViewController.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/03/13.
//

import UIKit
import AVFoundation
import SnapKit
import GoogleMobileAds

class HomeViewController: UIViewController {
    private let session = AVCaptureSession()
    private let colorModel = ColorModel()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let previewView: PreviewView = PreviewView()
    private var callCount = 0
    private var isCameraPaused = false
    private var initialScale: CGFloat = 1.0
    
    // throttle
    private let throttleInterval = 0.3
    private var lastCaptureTime: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAVCaptureSession()
        setupViewsAndLayout()
        UpdateManager.shared.checkForUpdate(viewController: self)
        
        // pause
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // zoom
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchCamera(_:)))
        self.view.addGestureRecognizer(pinch)
        
        AmplitudeManager.addLog(event: .SignIn)
    }
    
    @objc func handlePinchCamera(_ pinch: UIPinchGestureRecognizer) {
        let pinchScale = pinch.scale
        
        switch pinch.state {
        case .began:
            initialScale = selectDefaultDevice().videoZoomFactor
        case .changed:
            configureDeviceZoom(with: initialScale * pinchScale)
        default:
            break
        }
    }
    
    private func configureDeviceZoom(with newZoomFactor: CGFloat) {
        let device = selectDefaultDevice()
        
        let minAvailableZoomScale: CGFloat = 1.0
        let maxAvailableZoomScale = device.maxAvailableVideoZoomFactor
        
        do {
            try device.lockForConfiguration()
            defer {
                device.unlockForConfiguration()
            }
            
            if newZoomFactor < minAvailableZoomScale {
                device.videoZoomFactor = minAvailableZoomScale
            } else if newZoomFactor > maxAvailableZoomScale {
                device.videoZoomFactor = maxAvailableZoomScale
            } else {
                device.videoZoomFactor = newZoomFactor
            }
            
        } catch {
            print("Error configuring device zoom: \(error)")
        }
    }
    
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if isCameraPaused {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
            isCameraPaused = false
            AmplitudeManager.addLog(event: .ColorCatch)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.stopRunning()
            }
            isCameraPaused = true
        }
    }
    
    
    func setupAVCaptureSession() {
        sessionQueue.async { [self] in
            session.beginConfiguration()
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: selectDefaultDevice()), session.canAddInput(videoDeviceInput) else { return }
            session.addInput(videoDeviceInput)
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            guard session.canAddOutput(videoDataOutput) else { return }
            videoDataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: sessionQueue)
            session.sessionPreset = .high
            session.addOutput(videoDataOutput)
            session.commitConfiguration()
            session.startRunning()
        }
    }
    
    func selectDefaultDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Default device fail")
            
        }
    }
    
    // Check user permisson status
    public func checkCameraPermission() {
        CameraPermissionManager.shared.checkCameraPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.previewView.session = self.session
            } else {
                self.showCameraPermissionAlert()
            }
        }
    }
    
    private func showCameraPermissionAlert() {
        // Show alert for camera permission
        let alertController = UIAlertController(
            title: "Currently do not have access to the camera.",
            message: "You can enable access in Settings > ColorCatcher tab.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) else { return }
            UIApplication.shared.open(settingsURL, options: [:])
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.previewView.setColorResult(name: "Camera Access Denied")
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
}

// Setup views and layout
extension HomeViewController {
    
    private func setupViewsAndLayout() {
        setupPreviewView()
    }
    
    // Setup preview
    private func setupPreviewView() {
        view.addSubview(previewView)
        
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("CreateCGImage fail")
        }
        
        let currentTime = Date().timeIntervalSinceReferenceDate
        let throttleIntervalAsDouble = Double(throttleInterval)
        if currentTime - lastCaptureTime >= throttleIntervalAsDouble {
            lastCaptureTime = currentTime
            updateColorResult(cgImage)
        }
    }
    
    private func updateColorResult(_ cgImage: CGImage) {
        let centerPoint = CGPoint(x: cgImage.width / 2, y: cgImage.height / 2)
        let uiColor = colorModel.getPixelColor(cgImage: cgImage, point: centerPoint)
        guard let colorName = colorModel.getColorName(forHex: uiColor.toHexString()) else { return }
        
        // Show color result
        DispatchQueue.main.async {
            self.view.backgroundColor = uiColor
            self.previewView.setColorResult(color: uiColor, name: colorName, hex: uiColor.toHexString())
        }
    }
    
}
