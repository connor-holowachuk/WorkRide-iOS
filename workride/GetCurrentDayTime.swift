//
//  GetCurrentDayTime.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-18.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func GetCurrentDayTime() -> Int {
    
    let nowTimeStamp = makeTimeStamp()
    
    let hour = nowTimeStamp.hour
    let minute = nowTimeStamp.minute
    let currentDayTime = (hour * 60) + minute
    
    return currentDayTime
    
}
