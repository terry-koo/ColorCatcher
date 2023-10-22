//
//  PreviewView.swift
//  MyColorPicker
//
//  Created by Terry Koo on 2023/03/14.
//

import UIKit
import AVFoundation


class PreviewView: UIView {
    private let BACKGROUND_BRIGHTNESS_THRESHOLD: CGFloat = 0.5
    private let blackWithAlpha = UIColor.black.withAlphaComponent(0.5)
    private let whiteWithAlpha = UIColor.white.withAlphaComponent(0.5)
    
    private let colorNameBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let colorNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private let hexValueBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let hexValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        return label
    }()
    
    private let dotView: UIView = UIView()
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    public func setColorResult(color: UIColor = UIColor.white, name: String, hex: String = "") {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                
                self.colorNameLabel.textColor = color
                self.colorNameLabel.text = name
                
                self.hexValueLabel.textColor = color
                self.hexValueLabel.text = hex
                
                let labelLuminance = color.luminance()
                
                if labelLuminance < self.BACKGROUND_BRIGHTNESS_THRESHOLD {
                    self.colorNameBackgroundView.backgroundColor = self.whiteWithAlpha
                    self.hexValueBackgroundView.backgroundColor = self.whiteWithAlpha
                } else {
                    self.colorNameBackgroundView.backgroundColor = self.blackWithAlpha
                    self.hexValueBackgroundView.backgroundColor = self.blackWithAlpha
                }
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewsAndLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension PreviewView {
    
    private func setupViewsAndLayout() {
        setupDotView()
        setupColorNameLabel()
        setupHexValueLabel()
    }
    
    private func setupDotView() {
        dotView.backgroundColor = .red
        dotView.layer.cornerRadius = 5
        addSubview(dotView)
        
        dotView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(10)
        }
    }
    
    private func setupColorNameLabel() {
        addSubview(colorNameBackgroundView)
        colorNameBackgroundView.addSubview(colorNameLabel)
        
        colorNameBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.centerY).offset(10)
        }
        
        colorNameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        colorNameBackgroundView.snp.makeConstraints { make in
            make.width.equalTo(colorNameLabel).multipliedBy(1.1)
            make.height.equalTo(colorNameLabel).multipliedBy(1.1)
        }
    }
    
    private func setupHexValueLabel() {
        addSubview(hexValueBackgroundView)
        hexValueBackgroundView.addSubview(hexValueLabel)
        
        hexValueBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        hexValueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        hexValueBackgroundView.snp.makeConstraints { make in
            make.width.equalTo(hexValueLabel).multipliedBy(1.2)
            make.height.equalTo(hexValueLabel).multipliedBy(1.2)
        }
    }
    
}
