//
//  GetDayOfWeek.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-07.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func getDayOfWeek(today:String)->Int? {
    
    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let todayDate = formatter.date(from: today) else { return nil }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    return weekDay
}
