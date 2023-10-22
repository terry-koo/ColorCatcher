//
//  AmplitudeManager.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/08/16.
//

import Foundation
import Amplitude

class AmplitudeManager {
    private static let shared = {
        Amplitude.instance().defaultTracking = AMPDefaultTrackingOptions.initWithAllEnabled()
        Amplitude.instance().initializeApiKey(Bundle.main.AMPLITUDE_API_KEY)
        return Amplitude.instance()
    }()
    
    static public func addLog(event: Event) {
        shared.logEvent(event.rawValue)
    }

    
    enum Event: String {
        case SignIn = "Sign in"
        case ColorCatch = "Color catch"
    }
}

