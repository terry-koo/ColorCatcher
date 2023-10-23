//
//  SystemModel.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/08/14.
//

import Foundation
import UIKit

struct System {
    // Current Version : Target -> General -> Version
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    // Current Build : Target -> General -> Build
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/AppleID"
    
    // Check appstore version
    func latestVersion(completion: @escaping (String?) -> Void) {
        let appleID = "6461213698"
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=\(appleID)&country=kr") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreVersion = results[0]["version"] as? String else {
                completion(nil)
                return
            }
            print("appleStoreVersion : \(appStoreVersion)")
            completion(appStoreVersion)
        }
        
        task.resume()
    }
    
    // move to appstore
    func openAppStore() {
        guard let url = URL(string: System.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
