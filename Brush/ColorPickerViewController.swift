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
        
        setupCloseBt()
        setupConfirmBt()
    }
    
    // MARK: Customized Methods
    func setupCloseBt() {
        let buttonWidth: CGFloat = 20
        let buttonViewWidth = buttonWidth + 10
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        closeButton.setImage(UIImage(named: "cross"), for: .normal)
        closeButton.addTarget(self, action: #selector(ColorPickerViewController.closeTapped), for: .touchUpInside)
        
        let closeButtonView = UIView(frame: CGRect(x: 0, y: 0, width: buttonViewWidth, height: buttonViewWidth))
        closeButtonView.addSubview(closeButton)
        
        closeButton.center = closeButtonView.center
        
        closeButtonView.backgroundColor = UIColor.white
        closeButtonView.frame.origin = CGPoint(x: self.view.bounds.width - buttonViewWidth - 20, y: 30)
        closeButtonView.layer.cornerRadius = buttonViewWidth / 2
        closeButtonView.layer.borderColor = ColorScheme.Orange.cgColor
        closeButtonView.layer.borderWidth = 3
        
        self.view.addSubview(closeButtonView)
    }
    
    func setupConfirmBt() {
        let buttonWidth: CGFloat = 20
        let buttonViewWidth = buttonWidth + 10
        
        let confirmButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        confirmButton.setImage(UIImage(named: "tick"), for: .normal)
        confirmButton.addTarget(self, action: #selector(ColorPickerViewController.confirmTapped), for: .touchUpInside)
        
        let confirmButtonView = UIView(frame: CGRect(x: 0, y: 0, width: buttonViewWidth, height: buttonViewWidth))
        confirmButtonView.addSubview(confirmButton)
        
        confirmButton.center = confirmButtonView.center
        
        confirmButtonView.backgroundColor = UIColor.white
        confirmButtonView.frame.origin = CGPoint(x: 20, y: 30)
        confirmButtonView.layer.cornerRadius = buttonViewWidth / 2
        confirmButtonView.layer.borderColor = ColorScheme.Orange.cgColor
        confirmButtonView.layer.borderWidth = 3
        
        self.view.addSubview(confirmButtonView)
    }
    
    func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func confirmTapped() {
        delegate?.selected(color: colorSelected, thickness: thicknessSelected)
        dismiss(animated: true, completion: nil)
    }
    
    func selected(color: UIColor, thickness: CGFloat) {
        colorSelected = color
        thicknessSelected = thickness
    }
}
