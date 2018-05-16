//
//  GetFutureServerTime.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-14.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

func GetFutureServerTime(currentSeverTime: Int, futureScheduleDate: ScheduleDate) -> (Int, Int) {
    let currentTimeStamp = makeTimeStamp()
    let currentDate = currentTimeStamp.makeDate()
    
    print("current date: \(currentDate)")
    var calendar = NSCalendar.current
    
    // to
    let futureTimeStampTo = futureScheduleDate.date
    futureTimeStampTo?.hour = (futureScheduleDate.startTime / 60)
    futureTimeStampTo?.minute = futureScheduleDate.startTime % 60
    
    print("future to timestamp: \((futureTimeStampTo?.makeDate())!)")
    
    let datecomponenetsTo = calendar.dateComponents([Calendar.Component.minute], from: currentDate, to: (futureTimeStampTo?.makeDate())!)
    let minutesTo = datecomponenetsTo.minute
    
    // from
    let futureTimeStampFrom = futureScheduleDate.date
    futureTimeStampFrom?.hour = (futureScheduleDate.finishTime / 60)
    futureTimeStampFrom?.minute = futureScheduleDate.finishTime % 60
    
    print("future to timestamp: \((futureTimeStampFrom?.makeDate())!)")
    
    let datecomponenetsFrom = calendar.dateComponents([Calendar.Component.minute], from: currentDate, to: (futureTimeStampFrom?.makeDate())!)
    let minutesFrom = datecomponenetsFrom.minute
    
    return (currentSeverTime + minutesTo!, currentSeverTime + minutesFrom!)
}
