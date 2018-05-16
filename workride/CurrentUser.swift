//
//  CurrentUser.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-02.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CurrentUser {
    // user information
    static var firstName = "friend"
    static var lastName = "lee"
    static var fullName = "my friend"
    
    static var firebaseUID = ""
    static var FirebaseInstanceToken = ""
    static var stripeAccountID = ""
    
    static var profileImage = UIImage(named: "generic-profile-image")
    
    static var email = "friend@gmail.com"
    static var phoneNumber = "(519) 403-5307"
    static var streetAddressA = ""
    static var streetAddressB = ""
    static var city = ""
    static var province = ""
    static var postalCode = ""
    static var country = ""
    
    static var isActiveDriver = false
    static var signedUpAsDriver = true
    
    static var pickupLocation = CLLocationCoordinate2D(latitude: 42.30443186653596, longitude: -83.06389323903024)
    static var fare : Int = 0
    static var seats : Int = 0
    
    // financial
    static var lastFourDigits: String = ""
    static var hasUploadedIDNumber = false
    static var hasUploadedIDDocument = false
    
    
    // business information
    static var business = Business()
    
    
    // schedule information
    static var schedule: [Int : Any] = [:] //[year:[month:[day:[to:ScheduleTrip, from:ScheduleTrip]]]]
    static var currentTrip = ScheduleTrip()
}

func resetCurrentUser() {
    CurrentUser.firstName = ""
    CurrentUser.lastName = ""
    CurrentUser.fullName = ""
    
    CurrentUser.firebaseUID = ""
    
    CurrentUser.profileImage = UIImage(named: "generic-profile-image")
    CurrentUser.FirebaseInstanceToken = ""
    CurrentUser.stripeAccountID = ""
    
    CurrentUser.email = ""
    CurrentUser.phoneNumber = ""
    CurrentUser.streetAddressA = ""
    CurrentUser.streetAddressB = ""
    CurrentUser.city = ""
    CurrentUser.province = ""
    CurrentUser.postalCode = ""
    CurrentUser.country = ""
    
    CurrentUser.isActiveDriver = false
    CurrentUser.signedUpAsDriver = false
    
    CurrentUser.pickupLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    CurrentUser.fare = 0
    CurrentUser.seats = 0
    
    CurrentUser.lastFourDigits = ""
    CurrentUser.hasUploadedIDNumber = false
    CurrentUser.hasUploadedIDDocument = false
    
    CurrentUser.business = Business()
    
    CurrentUser.schedule = [:]
    CurrentUser.currentTrip = ScheduleTrip()
}


