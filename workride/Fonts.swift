//
//  Fonts.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-29.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit

func getFont(_ fontNumber: Int!, screenHeight: CGFloat) -> UIFont {
    let goldenRatio: CGFloat = 1.61803398875
    
    let referenceFontSize = screenHeight * 0.03973013493
    let smallTextSize = referenceFontSize / goldenRatio
    let largeTextSize = referenceFontSize * goldenRatio
    
    let standard = UIFont(name: "AvenirNext-Regular", size: referenceFontSize)          //fontNumber = 0
    let standardBold = UIFont(name: "AvenirNext-Bold", size: referenceFontSize)         //fontNumber = 1
    let small = UIFont(name: "AvenirNext-Regular", size: smallTextSize)                 //fontNumber = 2
    let smallBold = UIFont(name: "AvenirNext-Bold", size: smallTextSize)                //fontNumber = 3
    let large = UIFont(name: "AvenirNext-Regular", size: largeTextSize)                 //fontNumber = 4
    
    let fontArray: [UIFont] = [standard!, standardBold!, small!, smallBold!, large!]
    
    return fontArray[fontNumber]
}
