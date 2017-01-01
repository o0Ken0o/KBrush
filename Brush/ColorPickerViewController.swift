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
    
    // TODO: set the default color of the color wheel as the currently selected color
    // TODO: set the brush color of the parent view controller
    
    var delegate: ColorPickerViewDelegate?
    var colorSelected = UIColor.white

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorPickerView = ColorPicker(frame: self.view.frame)
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
