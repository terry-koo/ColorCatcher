//
//  Bundle+Extension.swift
//  MyColorPicker
//
//  Created by Terry Koo on 10/22/23.
//

import Foundation

extension Bundle {
    
    var AMPLITUDE_API_KEY: String {
        guard let file = self.path(forResource: "MyColorPicker", ofType: "plist") else { return "" }
        guard let resource = NSDictionary (contentsOfFile: file) else { return "" }
        guard let key = resource["AMPLITUDE_API_KEY"] as? String else { fatalError("Bundle Error")}
        return key
    }
    
}
