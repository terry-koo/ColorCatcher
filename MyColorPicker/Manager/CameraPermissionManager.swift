//
//  CameraPermissionManager.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/08/14.
//

import AVFoundation

class CameraPermissionManager {
    static let shared = CameraPermissionManager()
    
    private init() {}
    
    // Check user camera permission status
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            requestAccess(completion: completion)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            fatalError("Unknown camera permission status")
        }
    }
    
    // Request camera permission
    private func requestAccess(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    } 
}
