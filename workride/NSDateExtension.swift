//
//  NSDateExtension.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-07.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

extension Date {
    func year() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.year, from: self)
        let year = components.year
        
        return year!
    }
    
    func month() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.month, from: self)
        let month = components.month
        
        return month!
    }
    
    func day() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let day = components.day
        
        return day!
    }
    
    func weekDay() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.weekday, from: self)
        let weekDay = components.weekday
        
        return weekDay!
    }
    
    func hour() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        //Return Hour
        return hour!
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        //Return Minute
        return minute!
    }
    
    func second() -> Int
    {
        //Get Second
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.second, from: self)
        let second = components.second
        
        //Return Second
        return second!
    }
    
    func timeInSeconds() -> Int
    {
        let hoursInSeconds = hour() * 3_600
        let minutesInSeconds = minute() * 60
        let seconds = second()
        let timeInSec = hoursInSeconds + minutesInSeconds + seconds
        
        return timeInSec
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
    
    func dayOfTheWeek() -> String? {
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Satudrday,"
        ]
        
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        let components: NSDateComponents = calendar.components(.weekday, from: self) as NSDateComponents
        return weekdays[components.weekday - 1]
    }
    
    
}
