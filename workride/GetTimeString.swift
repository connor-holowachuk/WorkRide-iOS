//
//  GetTimeString.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-03.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func GetTimeString(_ timeInt: Int) -> String {
    var hours = timeInt / 60
    let mins = timeInt % 60
    var ampm = "am"
    if hours >= 12 {
        ampm = "pm"
        if hours != 12 {
            hours -= 12
        }
    }
    
    var hoursString = hours.description
    var minsString = ""
    
    if mins < 10 {minsString = "0\(mins)"} else {minsString = mins.description}
    
    let finalString = hoursString + ":" + minsString + " " + ampm
    return finalString
}
