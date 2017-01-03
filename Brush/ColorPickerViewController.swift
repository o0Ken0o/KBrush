//
//  ColorPickerViewController.swift
//  Brush
//
//  Created by Kam Hei Siu on 1/1/2017.
//  Copyright © 2017 Ken Siu. All rights reserved.
//

import UIKit

protocol ColorPickerViewDelegate {
    func selected(color: UIColor, thickness: CGFloat)
}

class ColorPickerViewController: UIViewController, ColorPickerDelegate {
        
    var delegate: ColorPickerViewDelegate?
    var colorSelected: UIColor!
    var thicknessSelected: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorScheme.PaleYellow
        
        let colorPickerView = ColorPicker(frame: self.view.frame, currentColor: colorSelected, currentThickness: thicknessSelected)
        colorPickerView.delegate = self
        self.view.addSubview(colorPickerView)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        delegate?.selected(color: colorSelected, thickness: thicknessSelected)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func selected(color: UIColor, thickness: CGFloat) {
        colorSelected = color
        thicknessSelected = thickness
    }
}
