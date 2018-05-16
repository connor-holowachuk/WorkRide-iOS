//
//  UIViewExtensions.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-08.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addGradientWithColors(colorA: UIColor, colorB: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [colorA.cgColor, colorB.cgColor]
        //gradient.startPoint = CGPoint(x: 0, y: self.frame.height)
        //gradient.endPoint = CGPoint(x: self.frame.width, y: 0)
        
        layer.insertSublayer(gradient, at: 0)
    }
}
