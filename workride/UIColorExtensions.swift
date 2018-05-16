//
//  UIColorExtensions.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-29.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit

// add hex interpretation to UIColor
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

// define preset colors
extension UIColor {
    class func wrGreen() -> UIColor { return UIColor(hex: 0x21EC77) }
    class func wrBlue() -> UIColor { return UIColor(hex: 0x17E9A0) }
    class func wrGreenShadow() -> UIColor { return UIColor(hex: 0x1CC471).withAlphaComponent(0.7) }
    class func wrText() -> UIColor { return UIColor(hex: 0x444444) }
    class func wrLightText() -> UIColor { return UIColor(hex: 0xC1C1C1) }
    class func wrAlert() -> UIColor { return UIColor(hex: 0xF5A388) }
    class func wrWhite() -> UIColor { return UIColor(hex: 0xFFFFFF) }
    class func wrOffWhite() -> UIColor { return UIColor(hex: 0xFAFAFA) }
}
