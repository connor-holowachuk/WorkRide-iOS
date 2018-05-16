//
//  GetDaysInMonth.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-07.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func getDaysInMonth(month: Int, year: Int) -> Int {
    let calendar = NSCalendar.current
    
    let startComps = NSDateComponents()
    startComps.day = 1
    startComps.month = month
    startComps.year = year
    
    let endComps = NSDateComponents()
    endComps.day = 1
    endComps.month = month == 12 ? 1 : month + 1
    endComps.year = month == 12 ? year + 1 : year
    
    let startDate = calendar.date(from: startComps as DateComponents)!
    let endDate = calendar.date(from: endComps as DateComponents)!
    
    let diff = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
    return diff.day!
}
