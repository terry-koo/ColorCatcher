//
//  ColorModel.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/08/12.
//

import UIKit

class ColorModel {
    // Get color from image point
    func getPixelColor(cgImage: CGImage, point: CGPoint) -> UIColor {
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData: [UInt8] = Array(repeating: 0, count: width * height * bytesPerPixel)
        let context = CGContext(data: &pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let index = Int(point.y) * bytesPerRow + Int(point.x) * bytesPerPixel
        let r = CGFloat(pixelData[index]) / CGFloat(255.0)
        let g = CGFloat(pixelData[index + 1]) / CGFloat(255.0)
        let b = CGFloat(pixelData[index + 2]) / CGFloat(255.0)
        let a = CGFloat(pixelData[index + 3]) / CGFloat(255.0)
        
        let uiColor = UIColor(red: r, green: g, blue: b, alpha: a)
#if DEBUG
        print(uiColor)
#endif
        return uiColor
    }
    
    func getColorName(forHex hex: String) -> String? {
        guard let inputColor = UIColor(hexString: hex) else { return nil }
        
        var closestColorName: String?
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for (colorHex, colorName) in PrivateColorData.colors {
            if let dictionaryColor = UIColor(hexString: colorHex) {
                let distance = inputColor.distanceTo(color: dictionaryColor)
                if distance < minDistance {
                    minDistance = distance
                    closestColorName = colorName
                }
            }
        }
        return closestColorName
    }
    
}
