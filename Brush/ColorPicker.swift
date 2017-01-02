//
//  ColorPicker.swift
//  Brush
//
//  Created by Kam Hei Siu on 1/1/2017.
//  Copyright © 2017 Ken Siu. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
    func colorSelected(color: UIColor)
}

class ColorPicker: UIView {
    var gradientView: UIView!
    var colorWheelImageView: UIImageView!
    var thicknessView: UIView!
    
    var gradient: CAGradientLayer!
    var colorWheelRadius: CGFloat!
    var colorWheelCenter: CGPoint!
    
    var colorMarker: UIView!
    var brightnessMarker: UIView!
    
    var colorPicked: UIColor!
    var brightnessPicked: CGFloat?
    
    var isDraggingColorWheel = false
    var isDraggingAlphaMarker = false
    
    var delegate: ColorPickerDelegate?
    
    init(frame: CGRect, currentColor: UIColor) {
        super.init(frame: frame)
        
        colorPicked = currentColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ColorPicker.handleGesture(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ColorPicker.handleGesture(_:)))
        self.addGestureRecognizer(panGesture)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        var colorWheelFrame = self.bounds
        colorWheelFrame.size.width *= 0.8
        colorWheelFrame.size.height = colorWheelFrame.size.width
        colorWheelImageView = UIImageView(frame: colorWheelFrame)
        colorWheelImageView.image = UIImage(named: "color_wheel")
        colorWheelImageView.center = self.center
        
        colorWheelRadius = self.colorWheelImageView.frame.width / 2.0
        colorWheelCenter = CGPoint(x: colorWheelRadius, y: colorWheelRadius)
        
        colorMarker = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        colorMarker.layer.cornerRadius = 20
        colorMarker.layer.borderColor = UIColor.black.cgColor
        colorMarker.layer.borderWidth = 5
        colorMarker.backgroundColor = colorPicked
        colorMarker.center = CGPoint(x: colorWheelImageView.bounds.width / 2.0, y: colorWheelImageView.bounds.height / 2.0)
        colorWheelImageView.addSubview(colorMarker)
        
        let gradientViewFrame = CGRect(x: 0, y: colorWheelImageView.frame.origin.y + colorWheelImageView.bounds.height + 40, width: self.bounds.width * 0.8, height: 20)
        gradientView = UIView(frame: gradientViewFrame)
        gradientView.backgroundColor = UIColor.black
        gradientView.center.x = self.center.x
        
        gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        setGradientColor(color: UIColor.white)
        gradientView.layer.insertSublayer(gradient, at: 0)
        
        let thickness: CGFloat = 2
        brightnessMarker = UIView(frame: CGRect(x: 0, y: -thickness, width: 20, height: gradientView.bounds.height + 2 * thickness))
        brightnessMarker.layer.borderColor = UIColor.black.cgColor
        brightnessMarker.layer.borderWidth = thickness
        gradientView.addSubview(brightnessMarker)
        
        var thicknessFrame = self.frame
        thicknessFrame.size.width *= 0.8
        thicknessFrame.size.height = 40
        thicknessFrame.origin.x = frame.width * 0.1
        thicknessFrame.origin.y = self.center.y - colorWheelRadius - 20 - 40
        thicknessView = UIView(frame: thicknessFrame)
        
        self.addSubview(colorWheelImageView)
        self.addSubview(gradientView)
        self.addSubview(thicknessView)
        
        let hue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let saturation = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let brightness = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let alpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        colorPicked.getHue(hue, saturation: saturation, brightness: brightness, alpha: alpha)
        
        let r = Double((colorWheelRadius - 1.0) * saturation.pointee)
        let angleReflectedAlongX = Double(hue.pointee) * M_PI * 2
        let selectedX = r * cos(angleReflectedAlongX) + Double(colorWheelRadius - 1.0)
        let selectedY = r * sin(angleReflectedAlongX) * (-1) + Double(colorWheelRadius - 1.0)
        updateColorMarker(CGPoint(x: selectedX, y: selectedY))
        
        let brightnessX = gradientView.bounds.width * (1.0 - brightness.pointee)
        let brightnessY = gradientView.bounds.height / 2.0
        updateBrightnessMarker(CGPoint(x: brightnessX, y: brightnessY))
        
        thicknessView.backgroundColor = colorPicked
        
        hue.deallocate(capacity: 1)
        saturation.deallocate(capacity: 1)
        brightness.deallocate(capacity: 1)
        alpha.deallocate(capacity: 1)
    }
    
    func handleGesture(_ recognizer: UIGestureRecognizer) {
        
        if let tap = recognizer as? UITapGestureRecognizer {
            
            let wheelPt = tap.location(in: self.colorWheelImageView)
            if isWithinColorWheel(wheelPt) {
                updateColorMarker(wheelPt)
            }
            
            let gradientPt = tap.location(in: gradientView)
            if isWithinGradientView(gradientPt) {
                updateBrightnessMarker(gradientPt)
            }
        }
        
        if let pan = recognizer as? UIPanGestureRecognizer {
            
            let wheelPt = pan.location(in: self.colorWheelImageView)
            if isWithinColorWheel(wheelPt) {
                if !isDraggingAlphaMarker {
                    isDraggingColorWheel = true
                    let boundaryPt = findIntersectingPtWithColorWheelCircle(wheelPt)
                    updateColorMarker(boundaryPt)
                }
            } else {
                if isDraggingColorWheel {
                    let boundaryPt = findIntersectingPtWithColorWheelCircle(wheelPt)
                    updateColorMarker(boundaryPt)
                }
            }
            
            let gradientPt = pan.location(in: gradientView)
            if isWithinGradientView(gradientPt) {
                if !isDraggingColorWheel {
                    isDraggingAlphaMarker = true
                    let boundaryPt = findPtIntersectingGradientView(gradientPt)
                    updateBrightnessMarker(boundaryPt)
                }
            } else {
                if isDraggingAlphaMarker {
                    let boundaryPt = findPtIntersectingGradientView(gradientPt)
                    updateBrightnessMarker(boundaryPt)
                }
            }
            
            if pan.state == .ended {
                isDraggingColorWheel = false
                isDraggingAlphaMarker = false
                
                let boundaryPt = findPtIntersectingGradientView(brightnessMarker.center)
                colorPicked = getPixelColorAtPoint(point: boundaryPt, sourceView: gradientView)
                delegate?.colorSelected(color: colorPicked)
            }
        }
    }
    
    func updateColorMarker(_ cgPoint: CGPoint) {
        setColorMarkerColor(cgPoint)
        positionColorMark(cgPoint)
        updateColorPicked()
    }
    
    func setColorMarkerColor(_ cgPoint: CGPoint) {
        colorMarker.isHidden = true
        let color = getPixelColorAtPoint(point: cgPoint, sourceView: self.colorWheelImageView)
        colorMarker.isHidden = false
        colorMarker.backgroundColor = color
        setGradientColor(color: color)
    }
    
    func positionColorMark(_ cgPoint: CGPoint) {
        colorMarker.center = cgPoint
    }
    
    func updateColorPicked() {
        let tempColorChose = getPixelColorAtPoint(point: brightnessMarker.center, sourceView: gradientView)
        thicknessView.backgroundColor = tempColorChose
    }
    
    func findIntersectingPtWithColorWheelCircle(_ cgPoint: CGPoint) -> CGPoint {
        let xDetaP2 = pow(cgPoint.x - colorWheelCenter.x, 2)
        let yDetaP2 = pow(cgPoint.y - colorWheelCenter.y, 2)
        let distance = sqrt((xDetaP2 + yDetaP2))
        
        if distance >= colorWheelRadius {
            // handle the case at the boundary, always get black color at the boundary point
            // therefore, we need to get the point that is close to the boundary point instead
            // we find the point by using point of division
            let offset: CGFloat = 2.0
            let lineSegment = distance - (colorWheelRadius - offset)
            let newX = (colorWheelCenter.x * lineSegment + cgPoint.x * (colorWheelRadius - offset)) / distance
            let newY = (colorWheelCenter.y * lineSegment + cgPoint.y * (colorWheelRadius - offset)) / distance
            
            return CGPoint(x: newX, y: newY)
        }
        
        return cgPoint
    }
    
    func updateBrightnessMarker(_ cgPoint: CGPoint) {
        positionAlphaMark(cgPoint)
        updateColorPicked()
    }
    
    func positionAlphaMark(_ cgPoint: CGPoint) {
        brightnessMarker.center.x = cgPoint.x
    }
    
    func findPtIntersectingGradientView(_ cgPoint: CGPoint) -> CGPoint {
        // this offset is used to handle boundary pt
        let offset: CGFloat = 1
        let leftBound = gradientView.bounds.origin.x + offset
        let rightBound = gradientView.bounds.width - offset
        let topBound = gradientView.bounds.height - offset
        let bottomBound = gradientView.bounds.origin.y + offset
        
        var newX = cgPoint.x
        newX = newX <= leftBound ? leftBound : newX
        newX = newX >= rightBound ? rightBound : newX
        
        var newY = cgPoint.y
        newY = newY <= bottomBound ? bottomBound : newY
        newY = newY >= topBound ? topBound : newY
        
        return CGPoint(x: newX, y: newY)
    }
    
    func isWithinColorWheel(_ cgPoint: CGPoint) -> Bool {
        let xDetaP2 = pow(cgPoint.x - colorWheelCenter.x, 2)
        let yDetaP2 = pow(cgPoint.y - colorWheelCenter.y, 2)
        let radiusP2 = pow(colorWheelRadius, 2)
        
        if xDetaP2 + yDetaP2 < radiusP2 {
            return true
        }
        
        return false
        
    }
    
    func isWithinGradientView(_ cgPoint: CGPoint) -> Bool {
        let leftBound = gradientView.bounds.origin.x
        let rightBound = gradientView.bounds.width
        let topBound = gradientView.bounds.height
        let bottomBound = gradientView.bounds.origin.y
        
        let isWithinX = cgPoint.x >= leftBound && cgPoint.x <= rightBound
        let isWithinY = cgPoint.y >= bottomBound && cgPoint.y <= topBound
        
        return isWithinX && isWithinY
    }
    
    func getPixelColorAtPoint(point:CGPoint, sourceView: UIView) -> UIColor{
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        sourceView.layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate(capacity: 4)
        return color
    }
    
    func setGradientColor(color: UIColor) {
        gradient.colors = [color.cgColor, UIColor.black.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
}
