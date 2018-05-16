//
//  GetMoneyString.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-10.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func GetMoneyString(_ value: Int) -> String {
    let cents = value % 100
    let dollars = (value - cents) / 100
    
    var centsString = cents.description
    if cents < 10 {
        centsString = "0\(cents)"
    }
    
    return "$\(dollars).\(centsString)"
}
