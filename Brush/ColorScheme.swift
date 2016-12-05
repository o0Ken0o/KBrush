//
//  ColorScheme.swift
//  Brush
//
//  Created by Ken Siu on 5/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit

class ColorScheme {
    
    static let Red = genColor(red: 213, green: 39, blue: 51)
    static let Orange = genColor(red: 253, green: 164, blue: 41)
    static let Yellow = genColor(red: 254, green: 217, blue: 83)
    static let Green = genColor(red: 148, green: 217, blue: 103)
    static let Blue = genColor(red: 27, green: 118, blue: 236)
    static let Purple = genColor(red: 147, green: 71, blue: 194)
    static let Black = genColor(red: 0, green: 0, blue: 0)
    
    static var Random: UIColor {
        get {
            let red = CGFloat(arc4random_uniform(255))
            let green = CGFloat(arc4random_uniform(255))
            let blue = CGFloat(arc4random_uniform(255))
            
            return genColor(red: red, green: green, blue: blue)
        }
    }
    
    static private func genColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}
