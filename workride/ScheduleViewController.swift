//
//  ScheduleViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-05.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ScheduleViewController: UIViewController, UIScrollViewDelegate {
    
    //important constant definitions
    let goldenRatio : CGFloat = 1.61803398875
    let textExtraSpaceFactor : CGFloat = 1.25
    var standardLabelHeight: CGFloat = 0.0
    var smallLabelHeight: CGFloat = 0.0
    var sideMargin: CGFloat = 0.0
    var smallSideMargin: CGFloat = 0.0
    var standardWidth: CGFloat = 0.0
    var smallCircleWidth: CGFloat = 0.0
    var riderPicCircleWidth: CGFloat = 0.0
    
    let headerView = UIView()
    let headerLabel = UILabel()
    let menuImageView = UIImageView()
    let menuButton = UIButton()
    
    let driveTimeCardScrollView = UIScrollView()
    
    let currentDayCardView = UIView()
    let currentDayCardHeaderLabel = UILabel()
    let currentDayCardSubHeadLabel = UILabel()
    let startTextLabel = UILabel()
    let endTextLabel = UILabel()
    let startDescriptorLabel = UILabel()
    let endDescriptorLabel = UILabel()
    let startButton = UIButton()
    let endButton = UIButton()
    var isEditingStart = true
    let currentDayDoneButtonLabel = UILabel()
    let currentDayDoneButton = UIButton()
    let drivingLabel = UILabel()
    let offLabel = UILabel()
    let toggleDrivingButton = UIButton()
    let drivingSelectorView = UIView()
    let doneEditingTimeButton = UIButton()
    let doneEditingTimeLabel = UILabel()
    var isDriving = false
    
    var currentScheduleDateCell = ScheduleDateCell()
    
    let timePicker = UIDatePicker()
    
    var monthCardViews: [ScheduleCardView] = []
    var showingCardIndex = 0
    let showCardsAtATime = 5
    var maxCardIndex = 4
    
    var selectedDay: TimeStamp!
    var today: TimeStamp!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.wrOffWhite()
        //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.smallSideMargin = self.view.frame.width * 0.048
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        self.smallCircleWidth = self.view.frame.width * 0.052
        self.riderPicCircleWidth = self.view.frame.width * 0.168
        
        
        
        // header view
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.23)
        self.headerView.backgroundColor = UIColor.wrGreen()
        self.view.addSubview(self.headerView)
        
        self.headerLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.headerLabel.textColor = UIColor.wrWhite()
        self.headerLabel.textAlignment = NSTextAlignment.center
        self.headerLabel.text = "schedule"
        self.headerLabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.072, width: standardWidth, height: standardLabelHeight)
        self.headerView.addSubview(self.headerLabel)
        
        let menuImageWidth = self.view.frame.width * 0.104
        self.menuImageView.image = UIImage(named: "menu-burger")
        self.menuImageView.frame = CGRect(x: self.smallSideMargin, y: self.headerLabel.frame.origin.y - ((menuImageWidth - self.standardLabelHeight) / 2), width: menuImageWidth, height: menuImageWidth)
        self.headerView.addSubview(self.menuImageView)
        
        self.menuButton.frame = self.menuImageView.frame
        self.menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
        self.headerView.addSubview(self.menuButton)
        
        // scroll view
        self.driveTimeCardScrollView.frame = CGRect(x: 0, y: self.view.frame.height * 0.157, width: self.view.frame.width, height: self.view.frame.height * 0.769)
        self.driveTimeCardScrollView.isPagingEnabled = true
        self.driveTimeCardScrollView.showsHorizontalScrollIndicator = false
        self.driveTimeCardScrollView.showsVerticalScrollIndicator = false
        self.driveTimeCardScrollView.delegate = self
        self.view.addSubview(self.driveTimeCardScrollView)
        
        self.today = makeTimeStamp()
        self.selectedDay = self.today
        for index in 0..<self.showCardsAtATime{
            self.setUpNewCard(today.month + index, yearInt: today.year)
        }
        
        self.currentDayCardView.frame = CGRect(x: 0, y: self.view.frame.height * 0.74, width: self.view.frame.width, height: self.view.frame.height)
        self.currentDayCardView.layer.cornerRadius = self.view.frame.width * 0.036
        self.currentDayCardView.layer.shadowColor = UIColor.black.cgColor
        self.currentDayCardView.layer.shadowRadius = self.view.frame.width * 0.024
        self.currentDayCardView.layer.shadowOpacity = 0.2
        self.currentDayCardView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.currentDayCardView.backgroundColor = UIColor.wrWhite()
        self.view.addSubview(self.currentDayCardView)
        
        self.currentDayCardHeaderLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.currentDayCardHeaderLabel.textColor = UIColor.wrLightText()
        self.currentDayCardHeaderLabel.textAlignment = NSTextAlignment.left
        self.currentDayCardHeaderLabel.text = "today"
        self.currentDayCardHeaderLabel.frame = CGRect(x: self.smallSideMargin * 2, y: self.view.frame.height * 0.04, width: standardWidth, height: standardLabelHeight)
        self.currentDayCardView.addSubview(self.currentDayCardHeaderLabel)
        
        self.currentDayCardSubHeadLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.currentDayCardSubHeadLabel.textColor = UIColor.wrLightText()
        self.currentDayCardSubHeadLabel.textAlignment = NSTextAlignment.left
        self.currentDayCardSubHeadLabel.text = "\(GetMonthDescriptor(self.today.month)!) \(self.today.day)"
        self.currentDayCardSubHeadLabel.frame = CGRect(x: self.smallSideMargin * 2, y: self.currentDayCardHeaderLabel.frame.origin.y + self.currentDayCardHeaderLabel.frame.height, width: standardWidth, height: self.smallLabelHeight)
        self.currentDayCardView.addSubview(self.currentDayCardSubHeadLabel)
        
        
        var dateComponents = DateComponents()
        dateComponents.minute = 0
        dateComponents.hour = 7
        
        let userCal = Calendar.current
        let someTime = userCal.date(from: dateComponents)
        
        self.timePicker.datePickerMode = .time
        self.timePicker.minuteInterval = 15
        self.timePicker.setDate(someTime!, animated: false)
        self.timePicker.frame.origin = CGPoint(x: 0, y: self.view.frame.height - self.currentDayCardView.frame.origin.y)
        self.timePicker.addTarget(self, action: #selector(ScheduleViewController.timePickerValueChanged), for: .valueChanged)
        self.currentDayCardView.addSubview(self.timePicker)
        
        self.startTextLabel.text = "8:00 am"
        self.startTextLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.startTextLabel.textColor = UIColor.wrLightText()
        self.startTextLabel.adjustsFontSizeToFitWidth = true
        self.startTextLabel.textAlignment = .center
        self.startTextLabel.frame = CGRect(x: self.smallSideMargin * 2, y: self.view.frame.height * 0.15, width: (self.view.frame.width - (2 * self.smallSideMargin)) / 2, height: standardLabelHeight)
        self.currentDayCardView.addSubview(self.startTextLabel)
        
        self.endTextLabel.text = "4:00 pm"
        self.endTextLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.endTextLabel.textColor = UIColor.wrLightText()
        self.endTextLabel.adjustsFontSizeToFitWidth = true
        self.endTextLabel.textAlignment = .center
        self.endTextLabel.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height * 0.15, width: (self.view.frame.width - (2 * self.smallSideMargin)) / 2, height: standardLabelHeight)
        self.currentDayCardView.addSubview(self.endTextLabel)
        
        self.startDescriptorLabel.text = "start time"
        self.startDescriptorLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.startDescriptorLabel.textColor = UIColor.wrLightText()
        self.startDescriptorLabel.textAlignment = .center
        self.startDescriptorLabel.frame = CGRect(x: self.startTextLabel.frame.origin.x, y: self.startTextLabel.frame.origin.y + self.startTextLabel.frame.height, width: self.startTextLabel.frame.width, height: self.smallLabelHeight)
        self.currentDayCardView.addSubview(self.startDescriptorLabel)
        
        self.endDescriptorLabel.text = "end time"
        self.endDescriptorLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.endDescriptorLabel.textColor = UIColor.wrLightText()
        self.endDescriptorLabel.textAlignment = .center
        self.endDescriptorLabel.frame = CGRect(x: self.endTextLabel.frame.origin.x, y: self.endTextLabel.frame.origin.y + self.endTextLabel.frame.height, width: self.endTextLabel.frame.width, height: self.smallLabelHeight)
        self.currentDayCardView.addSubview(self.endDescriptorLabel)
        
        self.startButton.frame = self.startTextLabel.frame
        self.startButton.addTarget(self, action: #selector(ScheduleViewController.editTimeButtonPressed(_:)), for: .touchUpInside)
        self.currentDayCardView.addSubview(self.startButton)
        
        self.endButton.frame = self.endTextLabel.frame
        self.endButton.addTarget(self, action: #selector(ScheduleViewController.editTimeButtonPressed(_:)), for: .touchUpInside)
        self.currentDayCardView.addSubview(self.endButton)
        
        let drivingSelectorCentreY = self.currentDayCardHeaderLabel.frame.origin.y + (self.currentDayCardHeaderLabel.frame.height / 2)
        let drivingSelectorViewHeight = self.view.frame.height * 0.051
        let drivingSelectorViewWidth = self.view.frame.width * 0.21
        
        self.offLabel.text = "off"
        self.offLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.offLabel.textColor = UIColor.wrWhite()
        self.offLabel.textAlignment = .center
        self.offLabel.frame = CGRect(x: self.view.frame.width - self.smallSideMargin - drivingSelectorViewWidth, y: drivingSelectorCentreY - (drivingSelectorViewHeight / 2), width: drivingSelectorViewWidth, height: drivingSelectorViewHeight)
        
        
        if CurrentUser.signedUpAsDriver { self.drivingLabel.text = "driving" } else { self.drivingLabel.text = "working" }
        self.drivingLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.drivingLabel.textColor = UIColor.wrText()
        self.drivingLabel.textAlignment = .center
        self.drivingLabel.frame = CGRect(x: self.view.frame.width - self.smallSideMargin - (2 * drivingSelectorViewWidth), y: drivingSelectorCentreY - (drivingSelectorViewHeight / 2), width: drivingSelectorViewWidth, height: drivingSelectorViewHeight)
       
        
        self.drivingSelectorView.backgroundColor = UIColor.wrGreen()
        self.drivingSelectorView.layer.cornerRadius = drivingSelectorViewHeight / 2
        self.drivingSelectorView.frame = CGRect(x: self.offLabel.frame.origin.x, y: self.offLabel.frame.origin.y, width: drivingSelectorViewWidth, height: drivingSelectorViewHeight)
        self.drivingSelectorView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.drivingSelectorView.layer.shadowOpacity = 0.6
        self.drivingSelectorView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.drivingSelectorView.layer.shadowRadius = self.view.frame.height * 0.009
        self.currentDayCardView.addSubview(self.drivingSelectorView)
        self.currentDayCardView.addSubview(self.offLabel)
        self.currentDayCardView.addSubview(self.drivingLabel)
        
        self.toggleDrivingButton.frame = CGRect(x: self.drivingLabel.frame.origin.x, y: self.drivingLabel.frame.origin.y, width: 2 * drivingSelectorViewWidth, height: drivingSelectorViewHeight)
        self.toggleDrivingButton.addTarget(self, action: #selector(ScheduleViewController.changeDrivingDayStatus(_:)), for: .touchUpInside)
        self.currentDayCardView.addSubview(self.toggleDrivingButton)
        
        
        self.doneEditingTimeLabel.text = "done"
        self.doneEditingTimeLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.doneEditingTimeLabel.textColor = UIColor.wrGreen()
        self.doneEditingTimeLabel.textAlignment = .center
        self.doneEditingTimeLabel.frame = CGRect(x: 0, y: (self.view.frame.height * 0.68) - self.standardLabelHeight, width: self.currentDayCardView.frame.width, height: self.standardLabelHeight)
        self.currentDayCardView.addSubview(self.doneEditingTimeLabel)
        
        self.doneEditingTimeButton.frame = self.doneEditingTimeLabel.frame
        self.doneEditingTimeButton.addTarget(self, action: #selector(ScheduleViewController.doneEditingTimeButtonPressed(_:)), for: .touchUpInside)
        self.currentDayCardView.addSubview(self.doneEditingTimeButton)
        
    }
    
    func setUpNewCard(_ monthInt: Int, yearInt: Int) {
        
        let yearSchedDataTest = CurrentUser.schedule[yearInt]
        var yearSchedData : [Int : Any] = [:]
        var monthSchedData : [Int : Any] = [:]
        
        
        if yearSchedDataTest != nil {
            yearSchedData = yearSchedDataTest as! [Int : Any]
            let monthSchedDataTest = yearSchedData[monthInt]
            if monthSchedDataTest != nil {
                monthSchedData = yearSchedData[monthInt] as! [Int : Any]
            }
        }
        
        
        let daysInMonth = getDaysInMonth(month: monthInt, year: yearInt)
        let startingWeekDay = getDayOfWeek(today: "\(yearInt)-\(ConvertIntToTwoDigitString(monthInt))-01")
        
        let cardXPosition = self.view.frame.width * CGFloat(self.monthCardViews.count)
        
        let newCardView = ScheduleCardView()
        newCardView.frame.size = self.driveTimeCardScrollView.frame.size
        newCardView.frame.origin = CGPoint(x: cardXPosition, y: 0)
        
        self.driveTimeCardScrollView.addSubview(newCardView)
        self.monthCardViews.append(newCardView)
        self.driveTimeCardScrollView.contentSize.width = self.view.frame.width * CGFloat(self.monthCardViews.count)
        
        if monthSchedData.isEmpty {
            let newMonthRef = Database.database().reference().child("users").child("schedule").child(CurrentUser.firebaseUID).child(yearInt.description).child(monthInt.description)
            newMonthRef.observeSingleEvent(of: .value, with: {  (schedSnapshot) in
                let dataExists = schedSnapshot.exists()
                
                if dataExists {
                    let schedData = (schedSnapshot.value as? NSDictionary)!
                    
                    /* schedData = [26:[from:[id:"",ismatched:false,time:14260],
                     to:[id:"",ismatched:false,time:14260]],
                     27:[from:[id:"",ismatched:false,time:14260],
                     to:[id:"",ismatched:false,time:14260]],
                     ]
                     */
                    
                    print(schedData)
                    print("number of days: \(schedData.count)")
                    
                    var daysThrough = 0
                    var schedForMonth: [Int : Any] = [:]
                    
                    for (day, dayData) in schedData {
                        daysThrough += 1
                        var toDone = false
                        var fromDone = false
                        
                        print("day:\(day).")
                        
                        let dayData = (schedData[day] as? NSDictionary)!
                        
                        let dayString = day as! String
                        let dayInt = Int(dayString)!
                        let tripDate = makeTimeStamp()
                        tripDate.day = dayInt
                        
                        let fromTrip = ScheduleTrip()
                        let toTrip = ScheduleTrip()
                        
                        
                        // make to trip
                        let toData = (dayData["to"] as? NSDictionary)!
                        print("toData: \(toData)")
                        
                        toTrip.dayTimeStamp = tripDate
                        toTrip.rideID = (toData["id"] as? String)!
                        toTrip.ismatched = (toData["ismatched"] as? Bool)!
                        
                        let toTime = (toData["time"] as? Int)!
                        
                        let toDayRef = Database.database().reference().child("rides").child(CurrentUser.business.uid).child(CurrentUser.business.locationid).child("to").child(toTime.description).child("queue").child(toTrip.rideID)
                        toDayRef.observe(.value, with: {  (toSnapshot) in
                            let toRideData = toSnapshot.value as? NSDictionary
                            
                            // pull remaining TO data
                            toTrip.leaveClockTime = (toRideData?["leavetime"] as? Int)!
                            toTrip.leaveDayTime = (toRideData?["leavedaytime"] as? Int)!
                            toTrip.arriveClockTime = (toRideData?["arrivetime"] as? Int)!
                            toTrip.arriveDayTime = (toRideData?["arrivedaytime"] as? Int)!
                            
                            
                            // set up TO driver
                            let toDriver = ScheduleRider()
                            toTrip.driver = toDriver
                            toDriver.uid = (toRideData?["driveruid"] as? String)!
                            toDriver.pickupLocation.latitude = CLLocationDegrees((toRideData?["driverlat"] as? Float)!)
                            toDriver.pickupLocation.longitude = CLLocationDegrees((toRideData?["driverlng"] as? Float)!)
                            toDriver.firstName = (toRideData?["driverfirstname"] as? String)!
                            toDriver.leaveClockTime = (toRideData?["leavetime"] as? Int)!
                            toDriver.leaveDayTime = (toRideData?["leavedaytime"] as? Int)!
                            
                            let hasToRiders = toSnapshot.hasChild("riders")
                            if hasToRiders {
                                let ridersData = (toRideData?["riders"] as? NSArray)!
                                for riderIndex in 0..<ridersData.count {
                                    let newRider = ScheduleRider()
                                    let newRiderData = ridersData[riderIndex] as! NSDictionary
                                    
                                    newRider.uid = (newRiderData["uid"] as? String)!
                                    newRider.pickupLocation.latitude = CLLocationDegrees((newRiderData["lat"] as? Float)!)
                                    newRider.pickupLocation.longitude = CLLocationDegrees((newRiderData["lng"] as? Float)!)
                                    newRider.firstName = (newRiderData["firstname"] as? String)!
                                    newRider.leaveClockTime = (newRiderData["meettime"] as? Int)!
                                    let timeFromDriver = newRider.leaveClockTime - toDriver.leaveClockTime
                                    let newRiderLeaveClockTime = toTrip.leaveDayTime + timeFromDriver
                                    newRider.leaveDayTime = newRiderLeaveClockTime
                                    
                                    toTrip.riders.append(newRider)
                                    
                                }
                            }
                            toDone = true
                            if fromDone == true {
                                let scheduleDataForDay : [String : Any] = ["to":toTrip, "from":fromTrip]
                                schedForMonth[dayInt] = scheduleDataForDay
                                if daysThrough == schedForMonth.count {
                                    let currentYearData : [Int : Any] = [monthInt : schedForMonth]
                                    CurrentUser.schedule[yearInt] = currentYearData
                                    print(CurrentUser.schedule)
                                    self.setupCardUI(newCardView: newCardView, daysInMonth: daysInMonth, startingWeekDay: startingWeekDay!, monthSchedData: schedForMonth, monthInt: monthInt, yearInt: yearInt)
                                }
                            }
                        })
                        
                        // make from trip
                        let fromData = (dayData["from"] as? NSDictionary)!
                        print("fromData: \(fromData)")
                        
                        fromTrip.dayTimeStamp = tripDate
                        fromTrip.rideID = (fromData["id"] as? String)!
                        fromTrip.ismatched = (fromData["ismatched"] as? Bool)!
                        
                        let fromTime = (fromData["time"] as? Int)!
                        
                        let fromDayRef = Database.database().reference().child("rides").child(CurrentUser.business.uid).child(CurrentUser.business.locationid).child("from").child(fromTime.description).child("queue").child(fromTrip.rideID)
                        fromDayRef.observe(.value, with: {  (fromSnapshot) in
                            let fromRideData = fromSnapshot.value as? NSDictionary
                            
                            // pull remaining FROM data
                            fromTrip.leaveClockTime = (fromRideData?["leavetime"] as? Int)!
                            fromTrip.leaveDayTime = (fromRideData?["leavedaytime"] as? Int)!
                            fromTrip.arriveClockTime = (fromRideData?["arrivetime"] as? Int)!
                            fromTrip.arriveDayTime = (fromRideData?["arrivedaytime"] as? Int)!
                            
                            
                            // set up FROM driver
                            let fromDriver = ScheduleRider()
                            fromTrip.driver = fromDriver
                            fromDriver.uid = (fromRideData?["driveruid"] as? String)!
                            fromDriver.pickupLocation.latitude = CLLocationDegrees((fromRideData?["driverlat"] as? Float)!)
                            fromDriver.pickupLocation.longitude = CLLocationDegrees((fromRideData?["driverlng"] as? Float)!)
                            fromDriver.firstName = (fromRideData?["driverfirstname"] as? String)!
                            fromDriver.leaveClockTime = (fromRideData?["leavetime"] as? Int)!
                            fromDriver.leaveDayTime = (fromRideData?["leavedaytime"] as? Int)!
                            
                            let hasFromRiders = fromSnapshot.hasChild("riders")
                            if hasFromRiders {
                                let ridersData = (fromRideData?["riders"] as? NSArray)!
                                for riderIndex in 0..<ridersData.count {
                                    let newRider = ScheduleRider()
                                    let newRiderData = ridersData[riderIndex] as! NSDictionary
                                    
                                    newRider.uid = (newRiderData["uid"] as? String)!
                                    newRider.pickupLocation.latitude = CLLocationDegrees((newRiderData["lat"] as? Float)!)
                                    newRider.pickupLocation.longitude = CLLocationDegrees((newRiderData["lng"] as? Float)!)
                                    newRider.firstName = (newRiderData["firstname"] as? String)!
                                    newRider.leaveClockTime = (newRiderData["meettime"] as? Int)!
                                    let timeFromDriver = newRider.leaveClockTime - fromDriver.leaveClockTime
                                    let newRiderLeaveClockTime = fromTrip.leaveDayTime + timeFromDriver
                                    newRider.leaveDayTime = newRiderLeaveClockTime
                                    
                                    fromTrip.riders.append(newRider)
                                    
                                }
                            }
                            
                            fromDone = true
                            if toDone == true {
                                let scheduleDataForDay : [String : Any] = ["to":toTrip, "from":fromTrip]
                                schedForMonth[dayInt] = scheduleDataForDay
                                if daysThrough == schedForMonth.count {
                                    let currentYearData : [Int : Any] = [monthInt : schedForMonth]
                                    CurrentUser.schedule[yearInt] = currentYearData
                                    print(CurrentUser.schedule)
                                    self.setupCardUI(newCardView: newCardView, daysInMonth: daysInMonth, startingWeekDay: startingWeekDay!, monthSchedData: schedForMonth, monthInt: monthInt, yearInt: yearInt)
                                }
                            }
                        })
                    }
                } else {
                    // no data exists in db for monthInt
                    self.setupCardUI(newCardView: newCardView, daysInMonth: daysInMonth, startingWeekDay: startingWeekDay!, monthSchedData: monthSchedData, monthInt: monthInt, yearInt: yearInt)
                }
            })
        } else {
            // data for monthInt has already been pulled
            self.setupCardUI(newCardView: newCardView, daysInMonth: daysInMonth, startingWeekDay: startingWeekDay!, monthSchedData: monthSchedData, monthInt: monthInt, yearInt: yearInt)
        }
    }
    
    func setupCardUI(newCardView: ScheduleCardView, daysInMonth: Int, startingWeekDay: Int, monthSchedData: [Int : Any], monthInt: Int, yearInt: Int) {
        let cardYPosition = self.view.frame.height * 0.0165
        newCardView.cardView.frame = CGRect(x: self.smallSideMargin, y: cardYPosition, width: self.view.frame.width - (2 * self.smallSideMargin), height: self.driveTimeCardScrollView.frame.height - (3 * cardYPosition))
        newCardView.cardView.layer.cornerRadius = self.view.frame.width * 0.036
        newCardView.cardView.layer.shadowColor = UIColor.black.cgColor
        newCardView.cardView.layer.shadowRadius = self.view.frame.width * 0.024
        newCardView.cardView.layer.shadowOpacity = 0.2
        newCardView.cardView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        newCardView.cardView.backgroundColor = UIColor.wrWhite()
        newCardView.addSubview(newCardView.cardView)
        
        newCardView.monthLabel.font = getFont(1, screenHeight: self.view.frame.height)
        newCardView.monthLabel.textColor = UIColor.wrText()
        newCardView.monthLabel.textAlignment = NSTextAlignment.left
        newCardView.monthLabel.text = GetMonthDescriptor(monthInt)?.lowercased()
        newCardView.monthLabel.frame = CGRect(x: self.smallSideMargin * 2, y: self.view.frame.height * 0.05, width: standardWidth, height: standardLabelHeight)
        newCardView.cardView.addSubview(newCardView.monthLabel)
        
        newCardView.yearLabel.font = getFont(2, screenHeight: self.view.frame.height)
        newCardView.yearLabel.textColor = UIColor.wrLightText()
        newCardView.yearLabel.textAlignment = NSTextAlignment.left
        newCardView.yearLabel.text = "\(yearInt)"
        newCardView.yearLabel.frame = CGRect(x: self.smallSideMargin * 2, y: newCardView.monthLabel.frame.origin.y + newCardView.monthLabel.frame.height, width: standardWidth, height: self.smallLabelHeight)
        newCardView.cardView.addSubview(newCardView.yearLabel)
        
        
        print("monthInt: \(monthInt)")
        let minRequiredCells = daysInMonth + startingWeekDay
        var requiredRows = minRequiredCells / 7
        if minRequiredCells % 7 > 0 { requiredRows += 1 }
        let cellWidth = (newCardView.cardView.frame.width - (2 * self.smallSideMargin)) / 7
        let cellHeight = (self.view.frame.height * 0.427) / CGFloat(requiredRows)
        
        //print("monthInt: \(monthInt), startingWeekDay: \(startingWeekDay!), minRequiredCells: \(minRequiredCells), requiredRows: \(requiredRows)")
        let tableYPosition = self.view.frame.height * 0.123
        let cellDateLabelYPosition = (cellHeight - self.smallLabelHeight) / 2
        var creatingDate = 1
        
        let selectedDateViewWidth = cellWidth / 1.2
        newCardView.selectedDateView.backgroundColor = UIColor.wrGreen()
        newCardView.selectedDateView.frame.size = CGSize(width: selectedDateViewWidth, height: selectedDateViewWidth)
        newCardView.selectedDateView.layer.cornerRadius = selectedDateViewWidth / 2
        newCardView.cardView.addSubview(newCardView.selectedDateView)
        
        for rowIndex in 0..<requiredRows {
            var newRowOfCells: [ScheduleDateCell] = []
            for colIndex in 0...6 {
                
                let newCellXPos = self.smallSideMargin + (CGFloat(colIndex) * cellWidth)
                let newCellYPos = tableYPosition + (CGFloat(rowIndex) * cellHeight)
                
                let newCell = ScheduleDateCell()
                
                newCell.cellView.frame = CGRect(x: newCellXPos, y: newCellYPos, width: cellWidth, height: cellHeight)
                newCardView.cardView.addSubview(newCell.cellView)
                newRowOfCells.append(newCell)
                
                if rowIndex == 0 && colIndex < startingWeekDay - 1 || creatingDate > daysInMonth {
                    //print("skipping cell")
                } else {
                    //print("on date: \(creatingDate)")
                    
                    let newDateIndicatorViewHeight = self.view.frame.height * 0.012
                    
                    newCell.drivingIndicatorView.frame = CGRect(x: (newCell.cellView.frame.width - newDateIndicatorViewHeight) / 2, y: (newCell.cellView.frame.height - newDateIndicatorViewHeight) / 2, width: newDateIndicatorViewHeight, height: newDateIndicatorViewHeight)
                    newCell.drivingIndicatorView.backgroundColor = UIColor.wrLightText()
                    newCell.drivingIndicatorView.layer.cornerRadius = newDateIndicatorViewHeight / 2
                    newCell.drivingIndicatorView.isHidden = true
                    newCell.cellView.addSubview(newCell.drivingIndicatorView)
                    
                    newCell.dateLabel.font = getFont(2, screenHeight: self.view.frame.height)
                    newCell.dateLabel.textColor = UIColor.wrText()
                    newCell.dateLabel.textAlignment = NSTextAlignment.center
                    newCell.dateLabel.text = "\(creatingDate)"
                    newCell.dateLabel.frame = CGRect(x: 0, y: cellDateLabelYPosition, width: cellWidth, height: self.smallLabelHeight)
                    newCell.cellView.addSubview(newCell.dateLabel)
                    
                    let newDateTimeStamp = TimeStamp(Year: yearInt, Month: monthInt, Day: creatingDate, Hour: 0, Minute: 0)
                    newCell.date.date = newDateTimeStamp
                    newCell.date.isDriving = false
                    newCell.date.startTime = 480
                    newCell.date.finishTime = 960
                    
                    if creatingDate == today.day && monthInt == today.month && yearInt == today.year {
                        //print("absolute today")
                        newCell.dateLabel.font = getFont(3, screenHeight: self.view.frame.height)
                        newCell.dateLabel.textColor = UIColor.wrWhite()
                        newCardView.selectedDateView.frame.origin = CGPoint(x: newCellXPos + ((cellWidth - selectedDateViewWidth) / 2), y: newCellYPos + ((cellHeight - selectedDateViewWidth) / 2))
                        newCardView.selectedViewContents = newCell.cellView
                        newCardView.selectedDate = newCell.date
                        self.currentScheduleDateCell = newCell
                    } else if creatingDate == 1 {
                        //print("1st of zee months")
                        if monthInt != today.month {
                            newCell.dateLabel.textColor = UIColor.wrWhite()
                            newCardView.selectedDateView.frame.origin = CGPoint(x: newCellXPos + ((cellWidth - selectedDateViewWidth) / 2), y: newCellYPos + ((cellHeight - selectedDateViewWidth) / 2))
                            newCardView.selectedViewContents = newCell.cellView
                            newCardView.selectedDate = newCell.date
                        } else if yearInt != today.year && monthInt == today.month {
                            newCell.dateLabel.textColor = UIColor.wrWhite()
                            newCardView.selectedDateView.frame.origin = CGPoint(x: newCellXPos + ((cellWidth - selectedDateViewWidth) / 2), y: newCellYPos + ((cellHeight - selectedDateViewWidth) / 2))
                            newCardView.selectedViewContents = newCell.cellView
                            newCardView.selectedDate = newCell.date
                        }
                    }
                    
                    newCell.cellButton.frame.size = newCell.cellView.frame.size
                    newCell.cellButton.frame.origin = CGPoint.zero
                    newCell.cellButton.addTarget(self, action: #selector(ScheduleViewController.cellButtonPressed(_:)), for: .touchUpInside)
                    newCell.cellView.addSubview(newCell.cellButton)
                    
                    var daySchedDataTest = monthSchedData[creatingDate]
                    if daySchedDataTest != nil {
                        newCell.date.isDriving = true
                        let daySchedData = daySchedDataTest as? [String : ScheduleTrip]
                        let toData = daySchedData?["to"]
                        let fromData = daySchedData?["from"]
                        
                        newCell.date.startTime = (toData?.arriveDayTime)!
                        newCell.date.finishTime = (fromData?.leaveDayTime)!
                        
                        newCell.drivingIndicatorView.frame.origin.y = newCell.cellView.frame.height - newCell.drivingIndicatorView.frame.height
                        newCell.drivingIndicatorView.isHidden = false
                        if toData?.ismatched == true || fromData?.ismatched == true {
                            newCell.drivingIndicatorView.backgroundColor = UIColor.wrGreen()
                        }
                    }
                    
                    creatingDate += 1
                }
                
                
                
            }
            
            newCardView.dateCells.append(newRowOfCells)
        }
        print(newCardView.selectedDate.date.formatTimeStamp())
    }
    
    
    func cellButtonPressed(_ sender: UIButton) {
        self.currentScheduleDateCell.dateLabel.textColor = UIColor.wrText()
        
        for rowi in 0..<self.monthCardViews[self.showingCardIndex].dateCells.count {
            
            for coli in 0..<self.monthCardViews[self.showingCardIndex].dateCells[rowi].count {
                
                //print("r: \(rowi), c: \(coli)")
                if self.monthCardViews[self.showingCardIndex].dateCells[rowi][coli].cellButton == sender {
                    
                    let currentDate = self.monthCardViews[self.showingCardIndex].dateCells[rowi][coli]
                    self.currentScheduleDateCell = currentDate
                    self.monthCardViews[self.showingCardIndex].selectedDate = currentDate.date
                    self.startTextLabel.text = self.currentScheduleDateCell.date.getStartTimeString()
                    self.endTextLabel.text = self.currentScheduleDateCell.date.getFinishTimeString()
                    if self.isDriving != self.currentScheduleDateCell.date.isDriving {
                        self.changeDrivingDayStatus(self.toggleDrivingButton)
                    }
                    print(currentDate.date.isDriving)
                    print(currentDate.date.date.day)
                    
                    self.selectedDay = currentDate.date.date
                    
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.monthCardViews[self.showingCardIndex].selectedDateView.frame.origin = CGPoint(x: (sender.superview?.frame.origin.x)! + ((sender.frame.width - self.monthCardViews[self.showingCardIndex].selectedDateView.frame.width) / 2), y: (sender.superview?.frame.origin.y)! + ((sender.frame.height - self.monthCardViews[self.showingCardIndex].selectedDateView.frame.height) / 2))
                    }, completion: { (finished) in
                        self.monthCardViews[self.showingCardIndex].dateCells[rowi][coli].dateLabel.textColor = UIColor.wrWhite()
                    })
                    
                    //print("it's a match! date: \(currentDate)")
                    self.putDateCardAway(true, newDate: currentDate.date.date)
                }
            }
        }
        
        
        
    }
    
    func doneButtonPressed(_ sender: UIButton) {
        print("done button pressed")
    }
    
    func putDateCardAway(_ showNewCard: Bool, newDate: TimeStamp) {
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentDayCardView.frame.origin.y = self.view.frame.height * 1.1
        }, completion: { (finished) in
            if showNewCard {
                self.updateCurrentDayCard(newDate)
                self.showNewCard()
            }
        })
    }
    
    func showNewCard() {
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentDayCardView.frame.origin.y = self.view.frame.height * 0.74
        }, completion: { (finished) in
        
        })
    }
    
    func updateCurrentDayCard(_ newDate: TimeStamp) {
        let dayOfWeek = newDate.getDayOfWeekDescriptor()
        let monthOfYear = GetMonthDescriptor(newDate.month)
        
        self.currentDayCardHeaderLabel.text = dayOfWeek
        self.currentDayCardSubHeadLabel.text = "\(monthOfYear!) \(newDate.day)"
    }
    
    func changeDrivingDayStatus(_ sender: UIButton) {
        if self.isDriving {
            self.isDriving = false
            self.currentScheduleDateCell.date.isDriving = false
            
            
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.drivingSelectorView.frame.origin.x = self.offLabel.frame.origin.x
                self.offLabel.textColor = UIColor.wrWhite()
                self.drivingLabel.textColor = UIColor.wrText()
                
                self.currentDayCardHeaderLabel.textColor = UIColor.wrLightText()
                self.startTextLabel.textColor = UIColor.wrLightText()
                self.endTextLabel.textColor = UIColor.wrLightText()
                
                self.currentScheduleDateCell.drivingIndicatorView.alpha = 0.0
                self.currentScheduleDateCell.drivingIndicatorView.frame.origin.y = (self.currentScheduleDateCell.cellView.frame.height - self.currentScheduleDateCell.drivingIndicatorView.frame.height) / 2
                
            }, completion: { (finished) in
                self.currentScheduleDateCell.drivingIndicatorView.isHidden = true
            })
        } else {
            self.isDriving = true
            self.currentScheduleDateCell.date.isDriving = true
            
            self.currentScheduleDateCell.drivingIndicatorView.isHidden = false
            self.currentScheduleDateCell.drivingIndicatorView.alpha = 0.0
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.drivingSelectorView.frame.origin.x = self.drivingLabel.frame.origin.x
                self.drivingLabel.textColor = UIColor.wrWhite()
                self.offLabel.textColor = UIColor.wrText()
                
                self.currentDayCardHeaderLabel.textColor = UIColor.wrText()
                self.startTextLabel.textColor = UIColor.wrText()
                self.endTextLabel.textColor = UIColor.wrText()
                
                self.currentScheduleDateCell.drivingIndicatorView.frame.origin.y = self.currentScheduleDateCell.cellView.frame.height - self.currentScheduleDateCell.drivingIndicatorView.frame.height
                self.currentScheduleDateCell.drivingIndicatorView.alpha = 1.0
                
            }, completion: { (finished) in
                
            })
        }
    }
    
    func editTimeButtonPressed(_ sender: UIButton) {
        
        if self.isDriving == false {
            self.changeDrivingDayStatus(self.toggleDrivingButton)
        }
        
        if sender == self.startButton {
            print("start button")
            self.isEditingStart = true
            
            var hourString = ""
            var hourInt = 0
            var otherChars: [Character] = []
            let currentText = self.startTextLabel.text!
            let charArray = Array(currentText.characters)
            
            var passedColon = false
            for index in 0..<charArray.count {
                if charArray[index] == ":" { passedColon = true }
                if passedColon == false {
                    hourString += String(charArray[index])
                } else {
                    otherChars.append(charArray[index])
                }
            }
            
            hourInt = Int(hourString)!
            let minString = "\(otherChars[1])\(otherChars[2])"
            let aOrP = "\(otherChars[4])"
            if aOrP == "p" { hourInt += 12; print(hourInt) }
            
            var dateComponents = DateComponents()
            dateComponents.minute = Int(minString)
            dateComponents.hour = hourInt
        
            
            let userCal = Calendar.current
            let someTime = userCal.date(from: dateComponents)
            self.timePicker.setDate(someTime!, animated: true)
        } else {
            print("end button")
            self.isEditingStart = false
            
            var hourString = ""
            var hourInt = 0
            var otherChars: [Character] = []
            let currentText = self.endTextLabel.text!
            let charArray = Array(currentText.characters)
            
            var passedColon = false
            for index in 0..<charArray.count {
                if charArray[index] == ":" { passedColon = true }
                if passedColon == false {
                    hourString += String(charArray[index])
                } else {
                    otherChars.append(charArray[index])
                }
            }
            
            hourInt = Int(hourString)!
            let minString = "\(otherChars[1])\(otherChars[2])"
            let aOrP = "\(otherChars[4])"
            if aOrP == "p" { hourInt += 12; print(hourInt)}
            
            var dateComponents = DateComponents()
            dateComponents.minute = Int(minString)
            dateComponents.hour = hourInt
            
            
            
            let userCal = Calendar.current
            let someTime = userCal.date(from: dateComponents)
            self.timePicker.setDate(someTime!, animated: true)
        }
        
        
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentDayCardView.frame.origin.y = self.view.frame.height * 0.3
        }, completion: { (finished) in
            
        })
    }
    
    func doneEditingTimeButtonPressed(_ sender: UIButton) {
        
        self.currentScheduleDateCell.date.saveStartTimeInt(self.startTextLabel.text!)
        self.currentScheduleDateCell.date.saveFinishTimeInt(self.endTextLabel.text!)
        self.currentScheduleDateCell.date.isDriving = self.isDriving
        
        
        
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentDayCardView.frame.origin.y = self.view.frame.height * 0.74
        }, completion: { (finished) in
            self.setupCurrentDayInDB()
        })
    }
    
    
    func setupCurrentDayInDB() {
        print("ayeee")
        let ref = Database.database().reference()
        
        ref.child("notifications").observeSingleEvent(of: .value, with: {  (snapshot) in
            let data = snapshot.value as? NSDictionary
            let clockTime = (data?["clock"] as? Int)!
            print("clockTime = \(clockTime)")
            let (toTime, fromTime) = GetFutureServerTime(currentSeverTime: clockTime, futureScheduleDate: self.currentScheduleDateCell.date)
            
            // update Current User Sched
            let showingYear = self.selectedDay.year
            let showingMonth = self.selectedDay.month
            let showingDay = self.selectedDay.day
            
            let toSchedTrip = ScheduleTrip()
            let fromSchedTrip = ScheduleTrip()
            
            toSchedTrip.dayTimeStamp = self.selectedDay
            toSchedTrip.arriveDayTime = self.currentScheduleDateCell.date.startTime
            toSchedTrip.arriveClockTime = toTime
            
            fromSchedTrip.dayTimeStamp = self.selectedDay
            fromSchedTrip.leaveDayTime = self.currentScheduleDateCell.date.finishTime
            fromSchedTrip.leaveClockTime = fromTime
            
            if CurrentUser.schedule[showingYear] != nil {
                var currentYearData = CurrentUser.schedule[showingYear] as! [Int : Any]
                if currentYearData[showingMonth] != nil {
                    var currentMonthData = currentYearData[showingMonth] as! [Int: Any]
                    currentMonthData[showingDay] = ["to":toSchedTrip, "from":fromSchedTrip]
                    currentYearData[showingMonth] = currentMonthData
                    CurrentUser.schedule[showingYear] = currentYearData
                } else {
                    currentYearData[showingMonth] = [showingDay: ["to":toSchedTrip, "from":fromSchedTrip]]
                    CurrentUser.schedule[showingYear] = currentYearData
                }
            } else {
                CurrentUser.schedule[2017] = [showingMonth : [showingDay: ["to":toSchedTrip, "from":fromSchedTrip]]]
            }
            
            let currentTimeStamp = self.currentScheduleDateCell.date.date
            print("CurrentUser.firebaseUID: \(CurrentUser.firebaseUID)")
            print("currentTimeStamp: \(currentTimeStamp)")
            let driverQueueRef = ref.child("users").child("schedule").child(CurrentUser.firebaseUID).child((currentTimeStamp?.year.description)!).child((currentTimeStamp?.month.description)!).child((currentTimeStamp?.day.description)!)
            
            print("toTime: \(toTime), fromTime: \(fromTime)")
            
            let dataToPush: [String: Any] = ["to":["daytime": self.currentScheduleDateCell.date.startTime, "time":toTime, "id":"", "ismatched":false],
                                             "from":["daytime":self.currentScheduleDateCell.date.finishTime, "time":fromTime, "id":"", "ismatched":false]]
            
            driverQueueRef.setValue(dataToPush)
            
            
            
            if CurrentUser.signedUpAsDriver {
                
            } else {
                
            }
            
        })
        
        
    }
    
    
    func timePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.none
        if self.isEditingStart {
            self.startTextLabel.text = dateFormatter.string(from: sender.date).lowercased()
        } else {
            self.endTextLabel.text = dateFormatter.string(from: sender.date).lowercased()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("view did scroll")
        //print(scrollView.contentOffset)
        let pageIndex = Int(scrollView.contentOffset.x / self.view.frame.width)
        if pageIndex != self.showingCardIndex {
            print("page Index \(pageIndex)")
            self.showingCardIndex = pageIndex
            self.putDateCardAway(true, newDate: self.monthCardViews[self.showingCardIndex].selectedDate.date)
            
            if self.showingCardIndex == (self.maxCardIndex - 1) {
                print("make new cards")
                for index in 0..<self.showCardsAtATime {
                    var makeMonth = self.today.month + (self.maxCardIndex + 1) + (index)
                    var makeYear = self.today.year
                    
                    if makeMonth > 12 {
                        makeYear += 1
                        makeMonth -= 12
                    }
                    
                    print("make card with month: \(makeMonth), year: \(makeYear)")
                    self.setUpNewCard(makeMonth, yearInt: makeYear)
                }
                self.maxCardIndex += self.showCardsAtATime
            }
            
        }
    }

    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    //color of status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    //animate status bar back on screen
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
}



class ScheduleCardView: UIView {
    var cardView = UIView()
    
    var monthLabel = UILabel()
    var yearLabel = UILabel()
    
    var selectedDateView = UIView()
    var selectedViewContents = UIView()
    var selectedDate = ScheduleDate()
    
    var dateCells: [[ScheduleDateCell]] = [[]]
}

class ScheduleDateCell {
    var cellView = UIView()
    var dateLabel = UILabel()
    var drivingIndicatorView = UIView()
    var cellButton = UIButton()
    var date = ScheduleDate()
}

class ScheduleDate {
    var date: TimeStamp!
    var isDriving = false
    var startTime = 0
    var finishTime = 0
    var hasBooking = false
    
    func getStartTimeString() -> String {
        let hours = startTime / 60
        let mins = startTime % 60
        if hours >= 12 { return "\(hours - 12):\(ConvertIntToTwoDigitString(mins)) pm" } else { return "\(hours):\(ConvertIntToTwoDigitString(mins)) am" }
    }
    
    func getFinishTimeString() -> String {
        let hours = self.finishTime / 60
        let mins = self.finishTime % 60
        if hours >= 12 { return "\(hours - 12):\(ConvertIntToTwoDigitString(mins)) pm" } else { return "\(hours):\(ConvertIntToTwoDigitString(mins)) am" }
    }
    
    func saveStartTimeInt(_ timeString: String) {
        var hourString = ""
        var hourInt = 0
        var otherChars: [Character] = []
        let charArray = Array(timeString.characters)
        
        var passedColon = false
        for index in 0..<charArray.count {
            if charArray[index] == ":" { passedColon = true }
            if passedColon == false {
                hourString += String(charArray[index])
            } else {
                otherChars.append(charArray[index])
            }
        }
        
        hourInt = Int(hourString)!
        let minString = "\(otherChars[1])\(otherChars[2])"
        let aOrP = "\(otherChars[4])"
        if aOrP == "p" { hourInt += 12; print(hourInt)}
        let minInt = Int(minString)
        
        self.startTime = (hourInt * 60) + minInt!
        
    }
    
    func saveFinishTimeInt(_ timeString: String) {
        var hourString = ""
        var hourInt = 0
        var otherChars: [Character] = []
        let charArray = Array(timeString.characters)
        
        var passedColon = false
        for index in 0..<charArray.count {
            if charArray[index] == ":" { passedColon = true }
            if passedColon == false {
                hourString += String(charArray[index])
            } else {
                otherChars.append(charArray[index])
            }
        }
        
        hourInt = Int(hourString)!
        let minString = "\(otherChars[1])\(otherChars[2])"
        let aOrP = "\(otherChars[4])"
        if aOrP == "p" { hourInt += 12; print(hourInt)}
        let minInt = Int(minString)
        
        self.finishTime = (hourInt * 60) + minInt!
        
    }
}
