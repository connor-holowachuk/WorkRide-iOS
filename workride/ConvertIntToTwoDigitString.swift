//
//  ConvertIntToTwoDigitString.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-07.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func ConvertIntToTwoDigitString(_ number: Int) -> String {
    var twoDigitString: String!
    
    if number <= 9 {
        let oneDigitString = String(number)
        twoDigitString = "0\(oneDigitString)"
    } else {
        twoDigitString = String(number)
    }
    
    return twoDigitString
}
