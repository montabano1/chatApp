//
//  ColorPickerViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/3/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ChromaColorPicker

class ColorPickerViewController: UIViewController {
    
    
    @IBOutlet var colorDisplayView: UIView!
    
    let colorPicker = ChromaColorPicker()
    let brightnessSlider = ChromaBrightnessSlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorPicker()
        setupBrightnessSlider()
        setupColorPickerHandles()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private
    private var homeHandle: ChromaColorHandle! // reference to home handle
    
    private func setupColorPicker() {
        colorPicker.delegate = self
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorPicker)
        
        let verticalOffset = -defaultColorPickerSize.height / 6
        
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalOffset),
            colorPicker.widthAnchor.constraint(equalToConstant: defaultColorPickerSize.width),
            colorPicker.heightAnchor.constraint(equalToConstant: defaultColorPickerSize.height)
        ])
    }
    
    private func setupBrightnessSlider() {
        brightnessSlider.connect(to: colorPicker)
        
        // Style
        brightnessSlider.trackColor = UIColor.blue
        brightnessSlider.handle.borderWidth = 3.0 // Example of customizing the handle's properties.
        
        // Layout
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(brightnessSlider)
        
        NSLayoutConstraint.activate([
            brightnessSlider.centerXAnchor.constraint(equalTo: colorPicker.centerXAnchor),
            brightnessSlider.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 28),
            brightnessSlider.widthAnchor.constraint(equalTo: colorPicker.widthAnchor, multiplier: 0.9),
            brightnessSlider.heightAnchor.constraint(equalTo: brightnessSlider.widthAnchor, multiplier: brightnessSliderWidthHeightRatio)
        ])
    }
    
    private func setupColorPickerHandles() {
        addHomeHandle()
    }
    
    private func addHomeHandle() {
        homeHandle = colorPicker.addHandle(at: .blue)
        
    }
}

extension ColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        colorDisplayView.backgroundColor = color
        let swiftColor = color
        if let rgb = swiftColor.rgb() {
            print(rgb)
        } else {
            print("conversion failed")
        }
        
        if handle === homeHandle, let imageView = homeHandle.accessoryView as? UIImageView {
            let colorIsBright = color.isLight
            
            UIView.animate(withDuration: 0.2, animations: {
                imageView.tintColor = colorIsBright ? .black : .white
            }, completion: nil)
        }
    }
}
extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    convenience init(rgb: Int) {
        let iBlue = rgb & 0xFF
        let iGreen =  (rgb >> 8) & 0xFF
        let iRed =  (rgb >> 16) & 0xFF
        let iAlpha =  (rgb >> 24) & 0xFF
        self.init(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255,
                  blue: CGFloat(iBlue)/255, alpha: CGFloat(iAlpha)/255)
    }
}


private let defaultColorPickerSize = CGSize(width: 320, height: 320)
private let brightnessSliderWidthHeightRatio: CGFloat = 0.1

