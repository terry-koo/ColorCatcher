//
//  UpdateManager.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/08/14.
//

import Foundation
import UIKit

class UpdateManager {
    static let shared = UpdateManager()
    
    private init() {}
    
    func checkForUpdate(viewController: UIViewController) {
        System().latestVersion { appStoreVersion in
            if let appStoreVersion = appStoreVersion, let currentProjectVersion = System.appVersion {
                let splitMarketingVersion = appStoreVersion.split(separator: ".").map { String($0) }
                let splitCurrentProjectVersion = currentProjectVersion.split(separator: ".").map { String($0) }
                
                if splitCurrentProjectVersion.count >= 2 && splitMarketingVersion.count >= 2 {
                    let majorUpdateNeeded = splitCurrentProjectVersion[0] < splitMarketingVersion[0]
                    let minorUpdateNeeded = splitCurrentProjectVersion[1] < splitMarketingVersion[1]
                    
                    if majorUpdateNeeded || minorUpdateNeeded {
                        let alert = UIAlertController(title: "Update Alert", message: "There is a new version of ColorCatcher available. Please update to version \(appStoreVersion).", preferredStyle: .alert)
                        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                            System().openAppStore()
                        }
                        alert.addAction(updateAction)
                        DispatchQueue.main.async {
                            viewController.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
