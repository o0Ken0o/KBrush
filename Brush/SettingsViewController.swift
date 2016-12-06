//
//  SettingsViewController.swift
//  Brush
//
//  Created by Ken Siu on 5/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func changeBrushSizeOrColor(settingsVC: SettingsViewController, brushSize: CGFloat, brushColor: UIColor)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var brushSizeLabel: UILabel!
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var customColor: UIColor!
    var customBrushSize: CGFloat!
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redSlider.value = Float((customColor.cgColor.components?[0])!) * 255.0
        greenSlider.value = Float((customColor.cgColor.components?[1])!) * 255.0
        blueSlider.value = Float((customColor.cgColor.components?[2])!) * 255.0
        changeColor()
        
        brushSizeSlider.value = Float(customBrushSize)
        changeBrushSize()
        
        self.view.backgroundColor = ColorScheme.PaleYellow
    }

    @IBAction func brushSizeChanged(_ sender: Any) {
        changeBrushSize()
    }
    
    @IBAction func colorChanged(_ sender: UISlider) {
        switch sender.tag {
        case 0...2:
            changeColor()
        default:
            print("nothing")
        }
    }
    
    func changeColor() {
        customColor = UIColor(red: CGFloat(redSlider.value) / 255.0, green: CGFloat(greenSlider.value) / 255.0, blue: CGFloat(blueSlider.value) / 255.0, alpha: 1.0)
        brushSizeLabel.textColor = customColor
        delegate?.changeBrushSizeOrColor(settingsVC: self, brushSize: customBrushSize, brushColor: customColor)
    }
    
    func changeBrushSize() {
        customBrushSize = CGFloat(brushSizeSlider.value)
        brushSizeLabel.text = "\(Int(customBrushSize))"
        delegate?.changeBrushSizeOrColor(settingsVC: self, brushSize: customBrushSize, brushColor: customColor)
    }
    
}
