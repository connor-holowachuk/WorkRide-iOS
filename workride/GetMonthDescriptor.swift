//
//  GetMonthDescriptor.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-07.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func GetMonthDescriptor(_ monthInt: Int) -> String? {
    let months = [
        "Janurary",
        "Feburary",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "Novemeber",
        "December"
    ]
    return months[monthInt - 1]
}


