//
//  TimeStamp.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-07.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation

class TimeStamp {
    var year: Int = 1
    var month: Int = 1
    var day: Int = 1
    
    var hour: Int = 0
    var minute: Int = 0
    
    init(Year: Int, Month: Int, Day: Int, Hour: Int, Minute: Int) {
        year = Year
        month = Month
        day = Day
        hour = Hour
        minute = Minute
    }
    
    
    func formatTimeStamp() -> String {
        var formattedTimeStamp: String!
        
        let tripDay: String = ConvertIntToTwoDigitString(self.day)
        let tripMonth: String = ConvertIntToTwoDigitString(self.month)
        let tripYear: String = String(self.year)
        let tripHour: String = ConvertIntToTwoDigitString(self.hour)
        let tripMinute: String = ConvertIntToTwoDigitString(self.minute)
        
        formattedTimeStamp = "\(tripYear)-\(tripMonth)-\(tripDay)T\(tripHour):\(tripMinute)"
        return formattedTimeStamp
    }
    
    func formatDayTimeStamp() -> String {
        let tripDay: String = ConvertIntToTwoDigitString(self.day)
        let tripMonth: String = ConvertIntToTwoDigitString(self.month)
        let tripYear: String = String(self.year)
        
        let formattedTimeStamp = "\(tripYear)-\(tripMonth)-\(tripDay)"
        return formattedTimeStamp
    }
    
    func calculateDate() -> String {
        let monthsArray = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let currentMonth = monthsArray[month]
        let date = "\(currentMonth) \(day), \(year)"
        return date
    }
    
    func calculateTime() -> String {
        let dayNightTime: String!
        var adjustedHour = hour
        if hour < 12 {
            dayNightTime = "AM"
        } else {
            adjustedHour = hour - 12
            dayNightTime = "PM"
        }
        let time = "\(adjustedHour):\(minute)\(dayNightTime)"
        return time
    }
    
    func getMonthOfYearDescriptor() -> String {
        let monthsArray = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        if self.month != 0 {
            return monthsArray[self.month - 1]
        } else {
            return "January"
        }
    }
    
    
    func getDayOfWeekDescriptor() -> String? {
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: "\(self.year)-\(ConvertIntToTwoDigitString(self.month))-\(ConvertIntToTwoDigitString(self.day))") else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        
        return weekdays[weekDay - 1]
    }
    
    func makeDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = self.year
        dateComponents.month = self.month
        dateComponents.day = self.day
        dateComponents.timeZone = TimeZone(abbreviation: "EST")
        dateComponents.hour = self.hour
        dateComponents.minute = self.minute
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let someDateTime = userCalendar.date(from: dateComponents)
        
        return someDateTime!
    }
}

func makeTimeStamp() -> TimeStamp {
    let currentDate = Date()
    let timeStamp = TimeStamp(Year: currentDate.year(), Month: currentDate.month(), Day: currentDate.day(), Hour: currentDate.hour(), Minute: currentDate.minute())
    return timeStamp
}
