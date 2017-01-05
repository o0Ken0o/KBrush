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
    var colorPickerView: ColorPicker!
    
    var overlayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorScheme.PaleYellow
        
        setupColorPickerView()
        setupCloseBt()
        setupConfirmBt()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupOverlayView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        overlayView.removeFromSuperview()
    }
    
    
    // MARK: Customized Methods
    func setupOverlayView() {
        overlayView = UIView(frame: self.view.frame)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.7
        self.view.insertSubview(overlayView, belowSubview: colorPickerView)
    }
    
    func setupColorPickerView() {
        var frame = self.view.frame
        frame.origin.x += 25
        frame.origin.y += 40
        frame.size.width -= 25 * 2
        frame.size.height -= 40 * 2
        colorPickerView = ColorPicker(frame: frame, currentColor: colorSelected, currentThickness: thicknessSelected)
        colorPickerView.delegate = self
        colorPickerView.layer.cornerRadius = 10
        colorPickerView.layer.borderColor = ColorScheme.Orange.cgColor
        colorPickerView.layer.borderWidth = 3
        colorPickerView.backgroundColor = ColorScheme.PaleYellow
        self.view.addSubview(colorPickerView)
    }
    
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
        closeButtonView.center = CGPoint(x: colorPickerView.frame.origin.x + colorPickerView.frame.width, y: colorPickerView.frame.origin.y)
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
        confirmButtonView.center = colorPickerView.frame.origin
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
