//
//  ColorPickerViewController.swift
//  Brush
//
//  Created by Kam Hei Siu on 1/1/2017.
//  Copyright © 2017 Ken Siu. All rights reserved.
//

import UIKit

protocol ColorPickerViewDelegate {
    func colorSelected(color: UIColor)
}

class ColorPickerViewController: UIViewController, ColorPickerDelegate {
        
    var delegate: ColorPickerViewDelegate?
    var colorSelected: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorPickerView = ColorPicker(frame: self.view.frame, currentColor: colorSelected)
        colorPickerView.delegate = self
        self.view.addSubview(colorPickerView)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        delegate?.colorSelected(color: colorSelected)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func colorSelected(color: UIColor) {
        colorSelected = color
    }
}
