//
//  ScheduleTrip.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-04.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import CoreLocation

class ScheduleTrip {
    var rideID = ""
    var dayTimeStamp: TimeStamp!
    var leaveClockTime = 0
    var arriveClockTime = 0
    var leaveDayTime = 0
    var arriveDayTime = 0
    
    var ismatched = false
    
    var driver = ScheduleRider()
    var riders: [ScheduleRider] = []
}

class ScheduleRider {
    var uid = ""
    var firstName = ""
    var profileImage = UIImage()
    var leaveClockTime = 0
    var leaveDayTime = 0
    var pickupLocation = CLLocationCoordinate2D()
    var deviceID = ""
    var hasBeenNotified = false
    var hasArrived = false
    var fare = 0
}
