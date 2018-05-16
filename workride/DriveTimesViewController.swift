//
//  DriveTimesViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-03.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class DriveTimesViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
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
    let loadDaysAtATime = 7
    var driveTimeData : [[String:Any]] = [["dateidentifier":"today", "date":"june 6",
                                            "rides":[
                                                "to":[
                                                    "leavetime":346,
                                                    "arrivetime":372,
                                                    "riders":[
                                                        ["isDriver":false,"uid":"a","lat":0.0,"lng":0.0,"firstname":"sarah","pickuptime":354],
                                                        ["isDriver":false,"uid":"b","lat":0.0,"lng":0.0,"firstname":"mike","pickuptime":363],
                                                        ["isDriver":false,"uid":"a","lat":0.0,"lng":0.0,"firstname":"sarah","pickuptime":354],
                                                        ["isDriver":false,"uid":"b","lat":0.0,"lng":0.0,"firstname":"mike","pickuptime":363],
                                                        ["isDriver":false,"uid":"a","lat":0.0,"lng":0.0,"firstname":"sarah","pickuptime":354],
                                                        ["isDriver":false,"uid":"b","lat":0.0,"lng":0.0,"firstname":"mike","pickuptime":363]
                                                    ]
                                                ],
                                                "from":[
                                                    "leavetime":846,
                                                    "arrivetime":872,
                                                    "riders":[
                                                        ["isDriver":false,"uid":"b","lat":0.0,"lng":0.0,"firstname":"mike","pickuptime":854],
                                                        ["isDriver":false,"uid":"a","lat":0.0,"lng":0.0,"firstname":"sarah","pickuptime":854]
                                                    ]
                                                ]
                                            ]],
                                          ["dateidentifier":"tomorrow", "date":"june 7",
                                           "rides":[
                                                "from":[
                                                    "leavetime":846,
                                                    "arrivetime":872,
                                                    "riders":[
                                                        ["isDriver":false,"uid":"b","lat":0.0,"lng":0.0,"firstname":"mike","pickuptime":854],
                                                        ["isDriver":false,"uid":"a","lat":0.0,"lng":0.0,"firstname":"sarah","pickuptime":854]
                                                    ]
                                                ]
                                            ]],
                                          ["dateidentifier":"monday", "date":"june 8"]]
    var currentCardIndex = 0
    var maxCardIndex = 7
    
    var viewByWeekButtonView = UIView()
    var viewByWeekButtonLabel = UILabel()
    var viewByWeekButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.wrOffWhite()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
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
        self.headerLabel.text = "drive times"
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
        
        
        // create drive time data
        
        var tempDriveTimeData: [[String: Any]] = []
        var makingDay = makeTimeStamp()
        
        for index in 0..<self.loadDaysAtATime {
            
            
            var dateIdentifier = ""
            switch index {
            case 0:
                dateIdentifier = "today"
            case 1:
                dateIdentifier = "tomorrow"
            default:
                dateIdentifier = makingDay.getDayOfWeekDescriptor()!
            }
            let monthString = makingDay.getMonthOfYearDescriptor()
            var dayCardData : [String: Any] = ["dateidentifier":dateIdentifier, "date": "\(monthString) \(makingDay.day)"]

            if CurrentUser.schedule[makingDay.year] != nil {
                let yearSchedData = CurrentUser.schedule[makingDay.year] as! [Int : Any]
                if yearSchedData[makingDay.month] != nil {
                    let monthSchedData = yearSchedData[makingDay.month] as! [Int : Any]
                    if monthSchedData[makingDay.day] != nil {
                        let daySchedData = monthSchedData[makingDay.day] as! [String : ScheduleTrip]
                        
                        
                        let toData = daySchedData["to"]
                        let toLeaveTime = toData?.leaveDayTime
                        let toArriveTime = toData?.arriveDayTime
                        let toDriverData : [String : Any] = ["isDriver":true,"uid":toData?.driver.uid, "lat":toData?.driver.pickupLocation.latitude, "lng":toData?.driver.pickupLocation.longitude,"firstname":toData?.driver.firstName, "pickuptime":toData?.driver.leaveDayTime]
                        var toDataForCards : [String : Any] = ["leavetime":toLeaveTime!,"arrivetime":toArriveTime!]
                        
                        var toRiderData : [[String : Any]] = [toDriverData]
                        if (toData?.riders.count)! > 0 {
                            for riderIndex in 0..<(toData?.riders.count)! {
                                let newRider : [String : Any] = ["isDriver":false,"uid":toData?.riders[riderIndex].uid, "lat":toData?.riders[riderIndex].pickupLocation.latitude, "lng":toData?.riders[riderIndex].pickupLocation.longitude,"firstname":toData?.riders[riderIndex].firstName, "pickuptime":toData?.riders[riderIndex].leaveDayTime]
                                toRiderData.append(newRider)
                            }
                            toDataForCards["riders"] = toRiderData
                            
                        } else {
                            toDataForCards["riders"] = toRiderData
                        }
                        
                        
                        let fromData = daySchedData["from"]
                        let fromLeaveTime = fromData?.leaveDayTime
                        let fromArriveTime = fromData?.arriveDayTime
                        let fromDriverData : [String : Any] = ["isDriver":true,"uid":fromData?.driver.uid, "lat":toData?.driver.pickupLocation.latitude, "lng":fromData?.driver.pickupLocation.longitude,"firstname":fromData?.driver.firstName, "pickuptime":fromData?.driver.leaveDayTime]
                        var fromDataForCards : [String : Any] = ["leavetime":fromLeaveTime!,"arrivetime":fromArriveTime!]
                        
                        var fromRiderData : [[String : Any]] = [fromDriverData]
                        if (fromData?.riders.count)! > 0 {
                            for riderIndex in 0..<(toData?.riders.count)! {
                                let newRider : [String : Any] = ["isDriver":false,"uid":fromData?.riders[riderIndex].uid, "lat":fromData?.riders[riderIndex].pickupLocation.latitude, "lng":fromData?.riders[riderIndex].pickupLocation.longitude,"firstname":fromData?.riders[riderIndex].firstName, "pickuptime":fromData?.riders[riderIndex].leaveDayTime]
                                fromRiderData.append(newRider)
                            }
                            fromDataForCards["riders"] = fromRiderData
                            
                        } else {
                            fromDataForCards["riders"] = fromRiderData
                        }
                        
                        
                        
                        var daySchedRideData : [String : Any] = ["to":toDataForCards, "from":fromDataForCards]
                        dayCardData["rides"] = daySchedRideData
                    }
                }
            }
            tempDriveTimeData.append(dayCardData)
            let lookingAtDay = makingDay.day + 1
            let daysInMonth = getDaysInMonth(month: makingDay.month, year: makingDay.year)
            if lookingAtDay <= daysInMonth {
                makingDay.day += 1
            } else {
                if makingDay.month < 12 {
                    makingDay.month += 1
                    makingDay.day = 1
                } else {
                    makingDay.year += 1
                    makingDay.month = 1
                    makingDay.day = 1
                }
            }
        }
        
        self.driveTimeData = tempDriveTimeData
        let currentDayTime = GetCurrentDayTime()
        
        for index in 0..<self.driveTimeData.count {
            
            print("card index = \(index)")
            
            let newCardView = driveTimeCardView()
        
            let cardXPosition = self.view.frame.width * CGFloat(index)
            
            newCardView.frame.size = self.driveTimeCardScrollView.frame.size
            newCardView.frame.origin = CGPoint(x: cardXPosition, y: 0)
            
            
            let cardYPosition = self.view.frame.height * 0.0165
            newCardView.cardView.frame = CGRect(x: self.smallSideMargin, y: cardYPosition, width: self.view.frame.width - (2 * self.smallSideMargin), height: self.driveTimeCardScrollView.frame.height - (3 * cardYPosition))
            newCardView.cardView.layer.cornerRadius = self.view.frame.width * 0.036
            newCardView.cardView.layer.shadowColor = UIColor.black.cgColor
            newCardView.cardView.layer.shadowRadius = self.view.frame.width * 0.024
            newCardView.cardView.layer.shadowOpacity = 0.2
            newCardView.cardView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
            newCardView.cardView.backgroundColor = UIColor.wrWhite()
            newCardView.addSubview(newCardView.cardView)
            
            newCardView.headerLabel.font = getFont(1, screenHeight: self.view.frame.height)
            newCardView.headerLabel.textColor = UIColor.wrText()
            newCardView.headerLabel.textAlignment = NSTextAlignment.left
            newCardView.headerLabel.text = self.driveTimeData[index]["dateidentifier"] as? String
            newCardView.headerLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.0337, width: standardWidth, height: standardLabelHeight)
            newCardView.cardView.addSubview(newCardView.headerLabel)
            
            newCardView.dateLabel.font = getFont(2, screenHeight: self.view.frame.height)
            newCardView.dateLabel.textColor = UIColor.wrLightText()
            newCardView.dateLabel.textAlignment = NSTextAlignment.left
            newCardView.dateLabel.text = self.driveTimeData[index]["date"] as? String
            newCardView.dateLabel.frame = CGRect(x: self.smallSideMargin, y: newCardView.headerLabel.frame.origin.y + newCardView.headerLabel.frame.height, width: standardWidth, height: self.smallLabelHeight)
            newCardView.cardView.addSubview(newCardView.dateLabel)
            
            newCardView.toWorkLabel.font = getFont(2, screenHeight: self.view.frame.height)
            newCardView.toWorkLabel.textColor = UIColor.wrGreen()
            newCardView.toWorkLabel.textAlignment = NSTextAlignment.center
            newCardView.toWorkLabel.text = "to work"
            newCardView.toWorkLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.151, width: (newCardView.cardView.frame.width / 2) - self.smallSideMargin, height: self.smallLabelHeight)
            newCardView.cardView.addSubview(newCardView.toWorkLabel)
            
            newCardView.toWorkButton.addTarget(newCardView, action: #selector(newCardView.toWorkButtonPressed(_:)), for: .touchUpInside)
            newCardView.toWorkButton.frame = newCardView.toWorkLabel.frame
            newCardView.cardView.addSubview(newCardView.toWorkButton)
            
            newCardView.backHomeLabel.font = getFont(2, screenHeight: self.view.frame.height)
            newCardView.backHomeLabel.textColor = UIColor.wrText()
            newCardView.backHomeLabel.textAlignment = NSTextAlignment.center
            newCardView.backHomeLabel.text = "back home"
            newCardView.backHomeLabel.frame = CGRect(x: newCardView.cardView.frame.width / 2, y: self.view.frame.height * 0.151, width: (newCardView.cardView.frame.width / 2) - self.smallSideMargin, height: self.smallLabelHeight)
            newCardView.cardView.addSubview(newCardView.backHomeLabel)
            
            newCardView.backHomeButton.addTarget(newCardView, action: #selector(newCardView.backHomeButtonPressed(_:)), for: .touchUpInside)
            newCardView.backHomeButton.frame = newCardView.backHomeLabel.frame
            newCardView.cardView.addSubview(newCardView.backHomeButton)
            
            let tripSelectBarHeight = self.view.frame.height * 0.0045
            newCardView.tripSelectBarWidth = self.view.frame.width * 0.2453
            newCardView.tripSelectBarView.backgroundColor = UIColor.wrGreen()
            newCardView.tripSelectBarView.layer.cornerRadius = tripSelectBarHeight / 2
            newCardView.tripSelectBarView.frame = CGRect(x: self.smallSideMargin + ((newCardView.toWorkLabel.frame.width - newCardView.tripSelectBarWidth) / 2), y: newCardView.toWorkLabel.frame.origin.y + (newCardView.toWorkLabel.frame.height * 1.3), width: newCardView.tripSelectBarWidth, height: tripSelectBarHeight)
            newCardView.tripSelectBarView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
            newCardView.tripSelectBarView.layer.shadowOpacity = 0.7
            newCardView.tripSelectBarView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
            newCardView.tripSelectBarView.layer.shadowRadius = self.view.frame.height * 0.009
            newCardView.cardView.addSubview(newCardView.tripSelectBarView)
            
            newCardView.tripContentView.frame = CGRect(x: 0, y: self.view.frame.height * 0.218, width: newCardView.cardView.frame.width, height: self.view.frame.height * 0.457)
            newCardView.cardView.addSubview(newCardView.tripContentView)
            
            
            
            // populate cards
            newCardView.twContentView.frame.origin = CGPoint.zero
            newCardView.twContentView.frame.size = newCardView.tripContentView.frame.size
            newCardView.bhContentView.frame.origin = CGPoint.zero
            newCardView.bhContentView.frame.size = newCardView.tripContentView.frame.size
            newCardView.tripContentView.addSubview(newCardView.twContentView)
            
            if self.driveTimeData[index]["rides"] != nil {
                let tripPathCenterMargin = self.view.frame.width * 0.1524
                let tripLabelsMargin = self.view.frame.width * 0.277
                
                
                let ridersdata = self.driveTimeData[index]["rides"] as? NSDictionary
                if ridersdata?["to"] != nil {
                    
                    let todata = ridersdata?["to"] as? NSDictionary
                    let riderinfodata = todata?["riders"] as? NSArray
                    let driverLeaveTime = GetCurrentDayTime() //todata?["leavetime"] as! Int
                    
                    print("index = \(index), currentDayTime = \(currentDayTime)")
                    if index == 1 && currentDayTime >= (driverLeaveTime - GlobalParams.beforeTime) && currentDayTime <= (driverLeaveTime + GlobalParams.afterTime) {
                        // should leave for trip now
                        
                        let newLeaveNowView = LeaveNowTripView()
                        
                        newLeaveNowView.frame.size = newCardView.tripContentView.frame.size
                        newLeaveNowView.frame.origin = CGPoint.zero
                        newCardView.twContentView.addSubview(newLeaveNowView)
                        
                        
                        let longButtonHeight = self.view.frame.height * 0.0877
                        let longButtonWidth = self.view.frame.width * 0.65
                        
                        let newButtonView = UIView()
                        newButtonView.backgroundColor = UIColor.wrGreen()
                        newButtonView.layer.cornerRadius = longButtonHeight / 2
                        newButtonView.frame = CGRect(x: (newLeaveNowView.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.338, width: longButtonWidth, height: longButtonHeight)
                        newButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
                        newButtonView.layer.shadowOpacity = 0.7
                        newButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
                        newButtonView.layer.shadowRadius = self.view.frame.height * 0.009
                        newLeaveNowView.addSubview(newButtonView)
                        
                        let newButtonLabel = UILabel()
                        newButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
                        newButtonLabel.textColor = UIColor.wrWhite()
                        newButtonLabel.textAlignment = NSTextAlignment.center
                        newButtonLabel.text = "leave now"
                        newButtonLabel.frame.origin = CGPoint.zero
                        newButtonLabel.frame.size = newButtonView.frame.size
                        newButtonView.addSubview(newButtonLabel)
                        
                        let newButton = UIButton()
                        newButton.frame.origin = CGPoint.zero
                        newButton.frame.size = newButtonView.frame.size
                        newButton.addTarget(self, action: #selector(DriveTimesViewController.leaveNowButtonPressed(_:)), for: .touchUpInside)
                        newButtonView.addSubview(newButton)
                        
                        
                        let newTopLabel = UILabel()
                        newTopLabel.font = getFont(2, screenHeight: self.view.frame.height)
                        newTopLabel.textColor = UIColor.wrLightText()
                        newTopLabel.textAlignment = NSTextAlignment.center
                        newTopLabel.text = "leave by"
                        newTopLabel.frame = CGRect(x: 0, y: self.view.frame.height / 10, width: newLeaveNowView.frame.width, height: self.smallLabelHeight)
                        newLeaveNowView.addSubview(newTopLabel)
                        
                        let leaveTimeLabel = UILabel()
                        leaveTimeLabel.font = getFont(0, screenHeight: self.view.frame.height)
                        leaveTimeLabel.textColor = UIColor.wrText()
                        leaveTimeLabel.textAlignment = NSTextAlignment.center
                        leaveTimeLabel.text = GetTimeString(driverLeaveTime)
                        leaveTimeLabel.frame = CGRect(x: 0, y: self.view.frame.height * 0.139, width: newLeaveNowView.frame.width, height: self.standardLabelHeight)
                        newLeaveNowView.addSubview(leaveTimeLabel)
                        
                        let newBottomLabel = UILabel()
                        newBottomLabel.font = getFont(2, screenHeight: self.view.frame.height)
                        newBottomLabel.textColor = UIColor.wrLightText()
                        newBottomLabel.textAlignment = NSTextAlignment.center
                        newBottomLabel.text = "to be on time"
                        newBottomLabel.frame = CGRect(x: 0, y: self.view.frame.height * 0.193, width: newLeaveNowView.frame.width, height: self.smallLabelHeight)
                        newLeaveNowView.addSubview(newBottomLabel)
                        
                    } else {
                        
                        
                        let tripLineViewWidth = self.view.frame.width * 0.008
                        newCardView.twTripView.tripLineView.frame = CGRect(x: tripPathCenterMargin - (tripLineViewWidth / 2), y: self.view.frame.height * 0.0442, width: tripLineViewWidth, height: self.view.frame.height * 0.37)
                        newCardView.twTripView.tripLineView.backgroundColor = UIColor.wrLightText()
                        newCardView.twTripView.addSubview(newCardView.twTripView.tripLineView)
                        
                        newCardView.twTripView.leaveCircleView.frame = CGRect(x: tripPathCenterMargin - (self.smallCircleWidth / 2), y: self.view.frame.height * 0.0352, width: self.smallCircleWidth, height: self.smallCircleWidth)
                        newCardView.twTripView.leaveCircleView.backgroundColor = UIColor.wrGreen()
                        newCardView.twTripView.leaveCircleView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
                        newCardView.twTripView.leaveCircleView.layer.shadowOpacity = 0.7
                        newCardView.twTripView.leaveCircleView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
                        newCardView.twTripView.leaveCircleView.layer.shadowRadius = self.view.frame.height * 0.009
                        newCardView.twTripView.leaveCircleView.layer.cornerRadius = self.smallCircleWidth / 2
                        newCardView.twTripView.addSubview(newCardView.twTripView.leaveCircleView)
                        
                        newCardView.twTripView.leaveLabel.font = getFont(2, screenHeight: self.view.frame.height)
                        newCardView.twTripView.leaveLabel.textColor = UIColor.wrText()
                        newCardView.twTripView.leaveLabel.textAlignment = NSTextAlignment.left
                        newCardView.twTripView.leaveLabel.text = "leave at " + GetTimeString(todata?["leavetime"] as! Int)
                        newCardView.twTripView.leaveLabel.frame = CGRect(x: tripLabelsMargin, y: newCardView.twTripView.leaveCircleView.frame.origin.y + ((newCardView.twTripView.leaveCircleView.frame.height - self.smallLabelHeight) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.smallLabelHeight)
                        newCardView.twTripView.addSubview(newCardView.twTripView.leaveLabel)
                        
                        
                        newCardView.twTripView.arriveCircleView.frame = CGRect(x: tripPathCenterMargin - (self.smallCircleWidth / 2), y: self.view.frame.height * 0.395, width: self.smallCircleWidth, height: self.smallCircleWidth)
                        newCardView.twTripView.arriveCircleView.backgroundColor = UIColor.wrGreen()
                        newCardView.twTripView.arriveCircleView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
                        newCardView.twTripView.arriveCircleView.layer.shadowOpacity = 0.7
                        newCardView.twTripView.arriveCircleView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
                        newCardView.twTripView.arriveCircleView.layer.shadowRadius = self.view.frame.height * 0.009
                        newCardView.twTripView.arriveCircleView.layer.cornerRadius = self.smallCircleWidth / 2
                        newCardView.twTripView.addSubview(newCardView.twTripView.arriveCircleView)
                        
                        newCardView.twTripView.arriveLabel.font = getFont(2, screenHeight: self.view.frame.height)
                        newCardView.twTripView.arriveLabel.textColor = UIColor.wrText()
                        newCardView.twTripView.arriveLabel.textAlignment = NSTextAlignment.left
                        newCardView.twTripView.arriveLabel.text = "arrive at " + GetTimeString(todata?["arrivetime"] as! Int)
                        newCardView.twTripView.arriveLabel.frame = CGRect(x: tripLabelsMargin, y: newCardView.twTripView.arriveCircleView.frame.origin.y + ((newCardView.twTripView.arriveCircleView.frame.height - self.smallLabelHeight) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.smallLabelHeight)
                        newCardView.twTripView.addSubview(newCardView.twTripView.arriveLabel)
                        
                        
                        if riderinfodata?.count == 1 {
                            let currentRiderInfo = riderinfodata?[0] as? NSDictionary
                            let currentRiderIsDriver = currentRiderInfo?["isDriver"] as? Bool
                            let centerYPosition = (newCardView.twTripView.leaveCircleView.frame.origin.y + newCardView.twTripView.arriveCircleView.frame.origin.y + self.smallCircleWidth) / 2
                            
                            let newProfileImageView = UIImageView()
                            newProfileImageView.frame = CGRect(x: tripPathCenterMargin - (self.riderPicCircleWidth / 2), y: centerYPosition - (self.riderPicCircleWidth / 2), width: self.riderPicCircleWidth, height: self.riderPicCircleWidth)
                            newProfileImageView.layer.cornerRadius = self.riderPicCircleWidth / 2
                            newProfileImageView.clipsToBounds = true
                            newProfileImageView.contentMode = .scaleAspectFill
                            newCardView.twTripView.addSubview(newProfileImageView)
                            newCardView.twTripView.profileImageViews.append(newProfileImageView)
                            
                            let newLoadingSpinner = UIActivityIndicatorView()
                            newLoadingSpinner.frame = newProfileImageView.frame
                            newLoadingSpinner.hidesWhenStopped = true
                            newLoadingSpinner.color = UIColor.wrLightText()
                            newLoadingSpinner.startAnimating()
                            newCardView.twTripView.addSubview(newLoadingSpinner)
                            newCardView.twTripView.loadingImageSpinnerViews.append(newLoadingSpinner)
                            
                            let currentRiderUID = currentRiderInfo?["uid"] as! String
                            
                            let storage = Storage.storage()
                            let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                            let userImageRef = storageRef.child("userImages").child("driver").child(currentRiderUID).child("profileImage").child("image.jpg")
                            
                            userImageRef.downloadURL() {
                                (URL, error) -> Void in
                                
                                if error != nil {
                                    // Handle any errors
                                    newProfileImageView.image = UIImage(named: "generic-profile-image")
                                    newLoadingSpinner.stopAnimating()
                                } else {
                                    let imageData: NSData = NSData.init(contentsOf: URL!)!
                                    let profileImage: UIImage = UIImage(data: imageData as Data)!
                                    newProfileImageView.image = profileImage
                                    newLoadingSpinner.stopAnimating()
                                }
                            }
                            
                            let newNameLabel = UILabel()
                            newNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
                            newNameLabel.textColor = UIColor.wrText()
                            newNameLabel.textAlignment = NSTextAlignment.left
                            newNameLabel.text = currentRiderInfo?["firstname"] as! String
                            newNameLabel.frame = CGRect(x: tripLabelsMargin, y: newProfileImageView.frame.origin.y + ((newProfileImageView.frame.height - (self.smallLabelHeight + self.standardLabelHeight)) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.standardLabelHeight)
                            newCardView.twTripView.addSubview(newNameLabel)
                            
                            let newTimeLabel = UILabel()
                            newTimeLabel.font = getFont(2, screenHeight: self.view.frame.height)
                            newTimeLabel.textColor = UIColor.wrText()
                            newTimeLabel.textAlignment = NSTextAlignment.left
                            if currentRiderIsDriver! { newTimeLabel.text = "your driver" } else { newTimeLabel.text = GetTimeString(currentRiderInfo?["pickuptime"] as! Int) }
                            newTimeLabel.frame = CGRect(x: tripLabelsMargin, y: newNameLabel.frame.origin.y + newNameLabel.frame.height, width: newNameLabel.frame.width, height: self.smallLabelHeight)
                            newCardView.twTripView.addSubview(newTimeLabel)
                            
                        } else if riderinfodata?.count == 2 {
                            let spacingHeight = (newCardView.twTripView.arriveCircleView.frame.origin.y - newCardView.twTripView.leaveCircleView.frame.origin.y + self.smallCircleWidth) / 3
                            for index in 0..<(riderinfodata?.count)! {
                                let imageYPosition = newCardView.twTripView.leaveCircleView.frame.origin.y + (CGFloat(index + 1) * spacingHeight)
                                let currentRiderInfo = riderinfodata?[index] as? NSDictionary
                                
                                let newProfileImageView = UIImageView()
                                newProfileImageView.frame = CGRect(x: tripPathCenterMargin - (self.riderPicCircleWidth / 2), y: imageYPosition - (self.riderPicCircleWidth / 2), width: self.riderPicCircleWidth, height: self.riderPicCircleWidth)
                                newProfileImageView.layer.cornerRadius = self.riderPicCircleWidth / 2
                                newProfileImageView.clipsToBounds = true
                                newProfileImageView.contentMode = .scaleAspectFill
                                newCardView.twTripView.addSubview(newProfileImageView)
                                newCardView.twTripView.profileImageViews.append(newProfileImageView)
                                
                                let newLoadingSpinner = UIActivityIndicatorView()
                                newLoadingSpinner.frame = newProfileImageView.frame
                                newLoadingSpinner.hidesWhenStopped = true
                                newLoadingSpinner.color = UIColor.wrLightText()
                                newLoadingSpinner.startAnimating()
                                newCardView.twTripView.addSubview(newLoadingSpinner)
                                newCardView.twTripView.loadingImageSpinnerViews.append(newLoadingSpinner)
                                
                                let currentRiderUID = currentRiderInfo?["uid"] as! String
                                
                                let storage = Storage.storage()
                                let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                                let userImageRef = storageRef.child("userImages").child("driver").child(currentRiderUID).child("profileImage").child("image.jpg")
                                
                                userImageRef.downloadURL() {
                                    (URL, error) -> Void in
                                    
                                    if error != nil {
                                        // Handle any errors
                                        newProfileImageView.image = UIImage(named: "generic-profile-image")
                                        newLoadingSpinner.stopAnimating()
                                    } else {
                                        let imageData: NSData = NSData.init(contentsOf: URL!)!
                                        let profileImage: UIImage = UIImage(data: imageData as Data)!
                                        newProfileImageView.image = profileImage
                                        newLoadingSpinner.stopAnimating()
                                    }
                                }
                                
                                let newNameLabel = UILabel()
                                newNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
                                newNameLabel.textColor = UIColor.wrText()
                                newNameLabel.textAlignment = NSTextAlignment.left
                                newNameLabel.text = currentRiderInfo?["firstname"] as! String
                                newNameLabel.frame = CGRect(x: tripLabelsMargin, y: newProfileImageView.frame.origin.y + ((newProfileImageView.frame.height - (self.smallLabelHeight + self.standardLabelHeight)) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.standardLabelHeight)
                                newCardView.twTripView.addSubview(newNameLabel)
                                
                                let newTimeLabel = UILabel()
                                newTimeLabel.font = getFont(2, screenHeight: self.view.frame.height)
                                newTimeLabel.textColor = UIColor.wrText()
                                newTimeLabel.textAlignment = NSTextAlignment.left
                                let currentRiderIsDriver = currentRiderInfo?["isDriver"] as? Bool
                                if currentRiderIsDriver! { newTimeLabel.text = "your driver" } else { newTimeLabel.text = GetTimeString(currentRiderInfo?["pickuptime"] as! Int) }
                                newTimeLabel.frame = CGRect(x: tripLabelsMargin, y: newNameLabel.frame.origin.y + newNameLabel.frame.height, width: newNameLabel.frame.width, height: self.smallLabelHeight)
                                newCardView.twTripView.addSubview(newTimeLabel)
                            }
                        } else {
                            let spacingHeight = (newCardView.twTripView.arriveCircleView.frame.origin.y - newCardView.twTripView.leaveCircleView.frame.origin.y + self.smallCircleWidth) / 3
                            for index in 0..<2 {
                                let imageYPosition = newCardView.twTripView.leaveCircleView.frame.origin.y + (CGFloat(index + 1) * spacingHeight)
                                let currentRiderInfo = riderinfodata?[index] as? NSDictionary
                                
                                let newProfileImageView = UIImageView()
                                newProfileImageView.frame = CGRect(x: tripPathCenterMargin - (self.riderPicCircleWidth / 2), y: imageYPosition - (self.riderPicCircleWidth / 2), width: self.riderPicCircleWidth, height: self.riderPicCircleWidth)
                                newProfileImageView.layer.cornerRadius = self.riderPicCircleWidth / 2
                                newProfileImageView.clipsToBounds = true
                                newProfileImageView.contentMode = .scaleAspectFill
                                newCardView.twTripView.addSubview(newProfileImageView)
                                newCardView.twTripView.profileImageViews.append(newProfileImageView)
                                
                                let newLoadingSpinner = UIActivityIndicatorView()
                                newLoadingSpinner.frame = newProfileImageView.frame
                                newLoadingSpinner.hidesWhenStopped = true
                                newLoadingSpinner.color = UIColor.wrLightText()
                                newLoadingSpinner.startAnimating()
                                newCardView.twTripView.addSubview(newLoadingSpinner)
                                newCardView.twTripView.loadingImageSpinnerViews.append(newLoadingSpinner)
                                
                                let currentRiderUID = currentRiderInfo?["uid"] as! String
                                
                                let storage = Storage.storage()
                                let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                                let userImageRef = storageRef.child("userImages").child("driver").child(currentRiderUID).child("profileImage").child("image.jpg")
                                
                                userImageRef.downloadURL() {
                                    (URL, error) -> Void in
                                    
                                    if error != nil {
                                        // Handle any errors
                                        newProfileImageView.image = UIImage(named: "generic-profile-image")
                                        newLoadingSpinner.stopAnimating()
                                    } else {
                                        let imageData: NSData = NSData.init(contentsOf: URL!)!
                                        let profileImage: UIImage = UIImage(data: imageData as Data)!
                                        newProfileImageView.image = profileImage
                                        newLoadingSpinner.stopAnimating()
                                    }
                                }
                                
                                let newNameLabel = UILabel()
                                newNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
                                newNameLabel.textColor = UIColor.wrText()
                                newNameLabel.textAlignment = NSTextAlignment.left
                                if index == 1 { newNameLabel.text = "\((riderinfodata?.count)! - 1) others"} else { newNameLabel.text = currentRiderInfo?["firstname"] as! String }
                                newNameLabel.frame = CGRect(x: tripLabelsMargin, y: newProfileImageView.frame.origin.y + ((newProfileImageView.frame.height - (self.smallLabelHeight + self.standardLabelHeight)) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.standardLabelHeight)
                                newCardView.twTripView.addSubview(newNameLabel)
                                
                                let newTimeLabel = UILabel()
                                newTimeLabel.font = getFont(2, screenHeight: self.view.frame.height)
                                newTimeLabel.textColor = UIColor.wrText()
                                newTimeLabel.textAlignment = NSTextAlignment.left
                                let currentRiderIsDriver = currentRiderInfo?["isDriver"] as? Bool
                                if currentRiderIsDriver! { newTimeLabel.text = "your driver" } else { newTimeLabel.text = GetTimeString(currentRiderInfo?["pickuptime"] as! Int) }
                                newTimeLabel.frame = CGRect(x: tripLabelsMargin, y: newNameLabel.frame.origin.y + newNameLabel.frame.height, width: newNameLabel.frame.width, height: self.smallLabelHeight)
                                newCardView.twTripView.addSubview(newTimeLabel)
                            }
                        }
                        
                        
                        newCardView.twTripView.frame.origin = CGPoint.zero
                        newCardView.twTripView.frame.size = newCardView.tripContentView.frame.size
                        
                        newCardView.twContentView.addSubview(newCardView.twTripView)
                    }
                
                } else {
                    newCardView.twUnbookedView.frame.origin = CGPoint.zero
                    newCardView.twUnbookedView.frame.size = newCardView.tripContentView.frame.size
                    
                    newCardView.twUnbookedView.headerLabel.font = getFont(0, screenHeight: self.view.frame.height)
                    newCardView.twUnbookedView.headerLabel.textColor = UIColor.wrText()
                    newCardView.twUnbookedView.headerLabel.textAlignment = NSTextAlignment.center
                    newCardView.twUnbookedView.headerLabel.text = "unbooked"
                    newCardView.twUnbookedView.headerLabel.frame = CGRect(x: 0, y: self.view.frame.height / 8, width: newCardView.twUnbookedView.frame.width, height: standardLabelHeight)
                    newCardView.twUnbookedView.addSubview(newCardView.twUnbookedView.headerLabel)
                    
                    newCardView.twUnbookedView.descriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
                    newCardView.twUnbookedView.descriptorTextView.textColor = UIColor.wrLightText()
                    newCardView.twUnbookedView.descriptorTextView.textAlignment = NSTextAlignment.center
                    newCardView.twUnbookedView.descriptorTextView.text = "there are no rides scheduled for you before work"
                    newCardView.twUnbookedView.descriptorTextView.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.199, width: newCardView.twUnbookedView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * 3)
                    newCardView.twUnbookedView.descriptorTextView.isEditable = false
                    newCardView.twUnbookedView.descriptorTextView.isSelectable = false
                    newCardView.twUnbookedView.descriptorTextView.isScrollEnabled = false
                    //newCardView.twUnbookedView.descriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
                    newCardView.twUnbookedView.addSubview(newCardView.twUnbookedView.descriptorTextView)
                    
                    newCardView.twContentView.addSubview(newCardView.twUnbookedView)
                }
                
                if ridersdata?["from"] != nil {
                    let fromdata = ridersdata?["from"] as? NSDictionary
                    let riderinfodata = fromdata?["riders"] as? NSArray
                    
                    
                    let tripLineViewWidth = self.view.frame.width * 0.008
                    newCardView.bhTripView.tripLineView.frame = CGRect(x: tripPathCenterMargin - (tripLineViewWidth / 2), y: self.view.frame.height * 0.0442, width: tripLineViewWidth, height: self.view.frame.height * 0.37)
                    newCardView.bhTripView.tripLineView.backgroundColor = UIColor.wrLightText()
                    newCardView.bhTripView.addSubview(newCardView.bhTripView.tripLineView)
                    
                    newCardView.bhTripView.leaveCircleView.frame = CGRect(x: tripPathCenterMargin - (self.smallCircleWidth / 2), y: self.view.frame.height * 0.0352, width: self.smallCircleWidth, height: self.smallCircleWidth)
                    newCardView.bhTripView.leaveCircleView.backgroundColor = UIColor.wrGreen()
                    newCardView.bhTripView.leaveCircleView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
                    newCardView.bhTripView.leaveCircleView.layer.shadowOpacity = 0.7
                    newCardView.bhTripView.leaveCircleView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
                    newCardView.bhTripView.leaveCircleView.layer.shadowRadius = self.view.frame.height * 0.009
                    newCardView.bhTripView.leaveCircleView.layer.cornerRadius = self.smallCircleWidth / 2
                    newCardView.bhTripView.addSubview(newCardView.bhTripView.leaveCircleView)
                    
                    newCardView.bhTripView.leaveLabel.font = getFont(2, screenHeight: self.view.frame.height)
                    newCardView.bhTripView.leaveLabel.textColor = UIColor.wrText()
                    newCardView.bhTripView.leaveLabel.textAlignment = NSTextAlignment.left
                    newCardView.bhTripView.leaveLabel.text = "leave at " + GetTimeString(fromdata?["leavetime"] as! Int)
                    newCardView.bhTripView.leaveLabel.frame = CGRect(x: tripLabelsMargin, y: newCardView.bhTripView.leaveCircleView.frame.origin.y + ((newCardView.bhTripView.leaveCircleView.frame.height - self.smallLabelHeight) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.smallLabelHeight)
                    newCardView.bhTripView.addSubview(newCardView.bhTripView.leaveLabel)
                    
                    
                    newCardView.bhTripView.arriveCircleView.frame = CGRect(x: tripPathCenterMargin - (self.smallCircleWidth / 2), y: self.view.frame.height * 0.395, width: self.smallCircleWidth, height: self.smallCircleWidth)
                    newCardView.bhTripView.arriveCircleView.backgroundColor = UIColor.wrGreen()
                    newCardView.bhTripView.arriveCircleView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
                    newCardView.bhTripView.arriveCircleView.layer.shadowOpacity = 0.7
                    newCardView.bhTripView.arriveCircleView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
                    newCardView.bhTripView.arriveCircleView.layer.shadowRadius = self.view.frame.height * 0.009
                    newCardView.bhTripView.arriveCircleView.layer.cornerRadius = self.smallCircleWidth / 2
                    newCardView.bhTripView.addSubview(newCardView.bhTripView.arriveCircleView)
                    
                    newCardView.bhTripView.arriveLabel.font = getFont(2, screenHeight: self.view.frame.height)
                    newCardView.bhTripView.arriveLabel.textColor = UIColor.wrText()
                    newCardView.bhTripView.arriveLabel.textAlignment = NSTextAlignment.left
                    newCardView.bhTripView.arriveLabel.text = "home at " + GetTimeString(fromdata?["arrivetime"] as! Int)
                    newCardView.bhTripView.arriveLabel.frame = CGRect(x: tripLabelsMargin, y: newCardView.bhTripView.arriveCircleView.frame.origin.y + ((newCardView.bhTripView.arriveCircleView.frame.height - self.smallLabelHeight) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.smallLabelHeight)
                    newCardView.bhTripView.addSubview(newCardView.bhTripView.arriveLabel)
                    
                    
                    if riderinfodata?.count == 1 {
                        let currentRiderInfo = riderinfodata?[0] as? NSDictionary
                        let centerYPosition = (newCardView.bhTripView.leaveCircleView.frame.origin.y + newCardView.bhTripView.arriveCircleView.frame.origin.y + self.smallCircleWidth) / 2
                        
                        let newProfileImageView = UIImageView()
                        newProfileImageView.frame = CGRect(x: tripPathCenterMargin - (self.riderPicCircleWidth / 2), y: centerYPosition - (self.riderPicCircleWidth / 2), width: self.riderPicCircleWidth, height: self.riderPicCircleWidth)
                        newProfileImageView.layer.cornerRadius = self.riderPicCircleWidth / 2
                        newProfileImageView.clipsToBounds = true
                        newProfileImageView.contentMode = .scaleAspectFill
                        newCardView.bhTripView.addSubview(newProfileImageView)
                        newCardView.bhTripView.profileImageViews.append(newProfileImageView)
                        
                        let newLoadingSpinner = UIActivityIndicatorView()
                        newLoadingSpinner.frame = newProfileImageView.frame
                        newLoadingSpinner.hidesWhenStopped = true
                        newLoadingSpinner.color = UIColor.wrLightText()
                        newLoadingSpinner.startAnimating()
                        newCardView.bhTripView.addSubview(newLoadingSpinner)
                        newCardView.bhTripView.loadingImageSpinnerViews.append(newLoadingSpinner)
                        
                        let currentRiderUID = currentRiderInfo?["uid"] as! String
                        
                        let storage = Storage.storage()
                        let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                        let userImageRef = storageRef.child("userImages").child("driver").child(currentRiderUID).child("profileImage").child("image.jpg")
                        
                        userImageRef.downloadURL() {
                            (URL, error) -> Void in
                            
                            if error != nil {
                                // Handle any errors
                                newProfileImageView.image = UIImage(named: "generic-profile-image")
                                newLoadingSpinner.stopAnimating()
                            } else {
                                let imageData: NSData = NSData.init(contentsOf: URL!)!
                                let profileImage: UIImage = UIImage(data: imageData as Data)!
                                newProfileImageView.image = profileImage
                                newLoadingSpinner.stopAnimating()
                            }
                        }
                        
                        
                        
                        
                        
                        let newNameLabel = UILabel()
                        newNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
                        newNameLabel.textColor = UIColor.wrText()
                        newNameLabel.textAlignment = NSTextAlignment.left
                        newNameLabel.text = currentRiderInfo?["firstname"] as! String
                        newNameLabel.frame = CGRect(x: tripLabelsMargin, y: newProfileImageView.frame.origin.y + ((newProfileImageView.frame.height - (self.smallLabelHeight + self.standardLabelHeight)) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.standardLabelHeight)
                        newCardView.bhTripView.addSubview(newNameLabel)
                        
                        let newTimeLabel = UILabel()
                        newTimeLabel.font = getFont(2, screenHeight: self.view.frame.height)
                        newTimeLabel.textColor = UIColor.wrText()
                        newTimeLabel.textAlignment = NSTextAlignment.left
                        let currentRiderIsDriver = currentRiderInfo?["isDriver"] as? Bool
                        if currentRiderIsDriver! { newTimeLabel.text = "your driver" } else { newTimeLabel.text = GetTimeString(currentRiderInfo?["pickuptime"] as! Int) }
                        newTimeLabel.frame = CGRect(x: tripLabelsMargin, y: newNameLabel.frame.origin.y + newNameLabel.frame.height, width: newNameLabel.frame.width, height: self.smallLabelHeight)
                        newCardView.bhTripView.addSubview(newTimeLabel)
                        
                    } else if riderinfodata?.count == 2 {
                        let spacingHeight = (newCardView.bhTripView.arriveCircleView.frame.origin.y - newCardView.bhTripView.leaveCircleView.frame.origin.y + self.smallCircleWidth) / 3
                        for index in 0..<(riderinfodata?.count)! {
                            let imageYPosition = newCardView.bhTripView.leaveCircleView.frame.origin.y + (CGFloat(index + 1) * spacingHeight)
                            let currentRiderInfo = riderinfodata?[index] as? NSDictionary
                            
                            let newProfileImageView = UIImageView()
                            newProfileImageView.frame = CGRect(x: tripPathCenterMargin - (self.riderPicCircleWidth / 2), y: imageYPosition - (self.riderPicCircleWidth / 2), width: self.riderPicCircleWidth, height: self.riderPicCircleWidth)
                            newProfileImageView.layer.cornerRadius = self.riderPicCircleWidth / 2
                            newProfileImageView.clipsToBounds = true
                            newProfileImageView.contentMode = .scaleAspectFill
                            newCardView.bhTripView.addSubview(newProfileImageView)
                            newCardView.bhTripView.profileImageViews.append(newProfileImageView)
                            
                            
                            let newLoadingSpinner = UIActivityIndicatorView()
                            newLoadingSpinner.frame = newProfileImageView.frame
                            newLoadingSpinner.hidesWhenStopped = true
                            newLoadingSpinner.color = UIColor.wrLightText()
                            newLoadingSpinner.startAnimating()
                            newCardView.bhTripView.addSubview(newLoadingSpinner)
                            newCardView.bhTripView.loadingImageSpinnerViews.append(newLoadingSpinner)
                            
                            let currentRiderUID = currentRiderInfo?["uid"] as! String
                            
                            let storage = Storage.storage()
                            let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                            let userImageRef = storageRef.child("userImages").child("driver").child(currentRiderUID).child("profileImage").child("image.jpg")
                            
                            userImageRef.downloadURL() {
                                (URL, error) -> Void in
                                
                                if error != nil {
                                    // Handle any errors
                                    newProfileImageView.image = UIImage(named: "generic-profile-image")
                                    newLoadingSpinner.stopAnimating()
                                } else {
                                    let imageData: NSData = NSData.init(contentsOf: URL!)!
                                    let profileImage: UIImage = UIImage(data: imageData as Data)!
                                    newProfileImageView.image = profileImage
                                    newLoadingSpinner.stopAnimating()
                                }
                            }
                            
                            
                            let newNameLabel = UILabel()
                            newNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
                            newNameLabel.textColor = UIColor.wrText()
                            newNameLabel.textAlignment = NSTextAlignment.left
                            newNameLabel.text = currentRiderInfo?["firstname"] as! String
                            newNameLabel.frame = CGRect(x: tripLabelsMargin, y: newProfileImageView.frame.origin.y + ((newProfileImageView.frame.height - (self.smallLabelHeight + self.standardLabelHeight)) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.standardLabelHeight)
                            newCardView.bhTripView.addSubview(newNameLabel)
                            
                            let newTimeLabel = UILabel()
                            newTimeLabel.font = getFont(2, screenHeight: self.view.frame.height)
                            newTimeLabel.textColor = UIColor.wrText()
                            newTimeLabel.textAlignment = NSTextAlignment.left
                            let currentRiderIsDriver = currentRiderInfo?["isDriver"] as? Bool
                            if currentRiderIsDriver! { newTimeLabel.text = "your driver" } else { newTimeLabel.text = GetTimeString(currentRiderInfo?["pickuptime"] as! Int) }
                            newTimeLabel.frame = CGRect(x: tripLabelsMargin, y: newNameLabel.frame.origin.y + newNameLabel.frame.height, width: newNameLabel.frame.width, height: self.smallLabelHeight)
                            newCardView.bhTripView.addSubview(newTimeLabel)
                        }
                        
                        
                    } else {
                        let spacingHeight = (newCardView.bhTripView.arriveCircleView.frame.origin.y - newCardView.bhTripView.leaveCircleView.frame.origin.y + self.smallCircleWidth) / 3
                        for index in 0..<2 {
                            let imageYPosition = newCardView.bhTripView.leaveCircleView.frame.origin.y + (CGFloat(index + 1) * spacingHeight)
                            let currentRiderInfo = riderinfodata?[index] as? NSDictionary
                            
                            let newProfileImageView = UIImageView()
                            newProfileImageView.frame = CGRect(x: tripPathCenterMargin - (self.riderPicCircleWidth / 2), y: imageYPosition - (self.riderPicCircleWidth / 2), width: self.riderPicCircleWidth, height: self.riderPicCircleWidth)
                            newProfileImageView.layer.cornerRadius = self.riderPicCircleWidth / 2
                            newProfileImageView.clipsToBounds = true
                            newProfileImageView.contentMode = .scaleAspectFill
                            newCardView.bhTripView.addSubview(newProfileImageView)
                            newCardView.bhTripView.profileImageViews.append(newProfileImageView)
                            
                            
                            let newLoadingSpinner = UIActivityIndicatorView()
                            newLoadingSpinner.frame = newProfileImageView.frame
                            newLoadingSpinner.hidesWhenStopped = true
                            newLoadingSpinner.color = UIColor.wrLightText()
                            newLoadingSpinner.startAnimating()
                            newCardView.bhTripView.addSubview(newLoadingSpinner)
                            newCardView.bhTripView.loadingImageSpinnerViews.append(newLoadingSpinner)
                            
                            let currentRiderUID = currentRiderInfo?["uid"] as! String
                            
                            let storage = Storage.storage()
                            let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                            let userImageRef = storageRef.child("userImages").child("driver").child(currentRiderUID).child("profileImage").child("image.jpg")
                            
                            userImageRef.downloadURL() {
                                (URL, error) -> Void in
                                
                                if error != nil {
                                    // Handle any errors
                                    newProfileImageView.image = UIImage(named: "generic-profile-image")
                                    newLoadingSpinner.stopAnimating()
                                } else {
                                    let imageData: NSData = NSData.init(contentsOf: URL!)!
                                    let profileImage: UIImage = UIImage(data: imageData as Data)!
                                    newProfileImageView.image = profileImage
                                    newLoadingSpinner.stopAnimating()
                                }
                            }
                            
                            
                            let newNameLabel = UILabel()
                            newNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
                            newNameLabel.textColor = UIColor.wrText()
                            newNameLabel.textAlignment = NSTextAlignment.left
                            if index == 1 { newNameLabel.text = "\((riderinfodata?.count)! - 1) others"} else { newNameLabel.text = currentRiderInfo?["firstname"] as! String }
                            newNameLabel.frame = CGRect(x: tripLabelsMargin, y: newProfileImageView.frame.origin.y + ((newProfileImageView.frame.height - (self.smallLabelHeight + self.standardLabelHeight)) / 2), width: newCardView.cardView.frame.width - tripLabelsMargin, height: self.standardLabelHeight)
                            newCardView.bhTripView.addSubview(newNameLabel)
                            
                            let newTimeLabel = UILabel()
                            newTimeLabel.font = getFont(2, screenHeight: self.view.frame.height)
                            newTimeLabel.textColor = UIColor.wrText()
                            newTimeLabel.textAlignment = NSTextAlignment.left
                            let currentRiderIsDriver = currentRiderInfo?["isDriver"] as? Bool
                            if currentRiderIsDriver! { newTimeLabel.text = "your driver" } else { newTimeLabel.text = GetTimeString(currentRiderInfo?["pickuptime"] as! Int) }
                            newTimeLabel.frame = CGRect(x: tripLabelsMargin, y: newNameLabel.frame.origin.y + newNameLabel.frame.height, width: newNameLabel.frame.width, height: self.smallLabelHeight)
                            newCardView.bhTripView.addSubview(newTimeLabel)
                        }
                    }
                    
                    
                    newCardView.bhTripView.frame.origin = CGPoint.zero
                    newCardView.bhTripView.frame.size = newCardView.tripContentView.frame.size
                    
                    newCardView.bhContentView.addSubview(newCardView.bhTripView)
                } else {
                    newCardView.bhUnbookedView.frame.origin = CGPoint.zero
                    newCardView.bhUnbookedView.frame.size = newCardView.tripContentView.frame.size
                    
                    newCardView.bhUnbookedView.headerLabel.font = getFont(0, screenHeight: self.view.frame.height)
                    newCardView.bhUnbookedView.headerLabel.textColor = UIColor.wrLightText()
                    newCardView.bhUnbookedView.headerLabel.textAlignment = NSTextAlignment.center
                    newCardView.bhUnbookedView.headerLabel.text = "unbooked"
                    newCardView.bhUnbookedView.headerLabel.frame = CGRect(x: 0, y: self.view.frame.height / 8, width: newCardView.twUnbookedView.frame.width, height: standardLabelHeight)
                    newCardView.bhUnbookedView.addSubview(newCardView.bhUnbookedView.headerLabel)
                    
                    newCardView.bhUnbookedView.descriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
                    newCardView.bhUnbookedView.descriptorTextView.textColor = UIColor.wrText()
                    newCardView.bhUnbookedView.descriptorTextView.textAlignment = NSTextAlignment.center
                    newCardView.bhUnbookedView.descriptorTextView.text = "there are no rides scheduled for you after work"
                    newCardView.bhUnbookedView.descriptorTextView.frame = CGRect(x: self.smallSideMargin + 4, y: self.view.frame.height * 0.199, width: newCardView.twUnbookedView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * 3)
                    newCardView.bhUnbookedView.descriptorTextView.isEditable = false
                    newCardView.bhUnbookedView.descriptorTextView.isSelectable = false
                    newCardView.bhUnbookedView.descriptorTextView.isScrollEnabled = false
                    //newCardView.bhUnbookedView.descriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
                    newCardView.bhUnbookedView.addSubview(newCardView.bhUnbookedView.descriptorTextView)
                    
                    newCardView.bhContentView.addSubview(newCardView.bhUnbookedView)
                }
            } else {
                newCardView.twUnbookedView.frame.origin = CGPoint.zero
                newCardView.twUnbookedView.frame.size = newCardView.tripContentView.frame.size
                newCardView.bhUnbookedView.frame.origin = CGPoint.zero
                newCardView.bhUnbookedView.frame.size = newCardView.tripContentView.frame.size
                
                newCardView.twUnbookedView.headerLabel.font = getFont(0, screenHeight: self.view.frame.height)
                newCardView.twUnbookedView.headerLabel.textColor = UIColor.wrText()
                newCardView.twUnbookedView.headerLabel.textAlignment = NSTextAlignment.center
                newCardView.twUnbookedView.headerLabel.text = "unbooked"
                newCardView.twUnbookedView.headerLabel.frame = CGRect(x: 0, y: self.view.frame.height / 8, width: newCardView.twUnbookedView.frame.width, height: standardLabelHeight)
                newCardView.twUnbookedView.addSubview(newCardView.twUnbookedView.headerLabel)
                
                newCardView.twUnbookedView.descriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
                newCardView.twUnbookedView.descriptorTextView.textColor = UIColor.wrLightText()
                newCardView.twUnbookedView.descriptorTextView.textAlignment = NSTextAlignment.center
                newCardView.twUnbookedView.descriptorTextView.text = "there are no rides scheduled for you before work"
                newCardView.twUnbookedView.descriptorTextView.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.199, width: newCardView.twUnbookedView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * 3)
                newCardView.twUnbookedView.descriptorTextView.isEditable = false
                newCardView.twUnbookedView.descriptorTextView.isSelectable = false
                newCardView.twUnbookedView.descriptorTextView.isScrollEnabled = false
                //newCardView.twUnbookedView.descriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
                newCardView.twUnbookedView.addSubview(newCardView.twUnbookedView.descriptorTextView)
                
                
                newCardView.bhUnbookedView.headerLabel.font = getFont(0, screenHeight: self.view.frame.height)
                newCardView.bhUnbookedView.headerLabel.textColor = UIColor.wrText()
                newCardView.bhUnbookedView.headerLabel.textAlignment = NSTextAlignment.center
                newCardView.bhUnbookedView.headerLabel.text = "unbooked"
                newCardView.bhUnbookedView.headerLabel.frame = CGRect(x: 0, y: self.view.frame.height / 8, width: newCardView.twUnbookedView.frame.width, height: standardLabelHeight)
                newCardView.bhUnbookedView.addSubview(newCardView.bhUnbookedView.headerLabel)
                
                newCardView.bhUnbookedView.descriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
                newCardView.bhUnbookedView.descriptorTextView.textColor = UIColor.wrLightText()
                newCardView.bhUnbookedView.descriptorTextView.textAlignment = NSTextAlignment.center
                newCardView.bhUnbookedView.descriptorTextView.text = "there are no rides scheduled for you after work"
                newCardView.bhUnbookedView.descriptorTextView.frame = CGRect(x: self.smallSideMargin + 4, y: self.view.frame.height * 0.199, width: newCardView.twUnbookedView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * 3)
                newCardView.bhUnbookedView.descriptorTextView.isEditable = false
                newCardView.bhUnbookedView.descriptorTextView.isSelectable = false
                newCardView.bhUnbookedView.descriptorTextView.isScrollEnabled = false
                //newCardView.bhUnbookedView.descriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
                newCardView.bhUnbookedView.addSubview(newCardView.bhUnbookedView.descriptorTextView)
                
                
                
                newCardView.twContentView.addSubview(newCardView.twUnbookedView)
                newCardView.bhContentView.addSubview(newCardView.bhUnbookedView)
            }
            
            self.driveTimeCardScrollView.addSubview(newCardView)
            self.driveTimeCardScrollView.contentSize.width = self.view.frame.width * CGFloat(self.driveTimeData.count)
        }
        
        self.viewByWeekButtonView.frame = CGRect(x: self.smallSideMargin, y: self.driveTimeCardScrollView.frame.origin.y + self.driveTimeCardScrollView.frame.height - self.smallSideMargin, width: self.view.frame.width - (2 * self.smallSideMargin), height: self.view.frame.height - (self.driveTimeCardScrollView.frame.origin.y + self.driveTimeCardScrollView.frame.height))
        self.view.addSubview(self.viewByWeekButtonView)
        
        self.viewByWeekButtonLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.viewByWeekButtonLabel.textColor = UIColor.wrLightText()
        self.viewByWeekButtonLabel.textAlignment = NSTextAlignment.center
        self.viewByWeekButtonLabel.text = "view by week"
        self.viewByWeekButtonLabel.frame.origin = CGPoint.zero
        self.viewByWeekButtonLabel.frame.size = self.viewByWeekButtonView.frame.size
        self.viewByWeekButtonView.addSubview(self.viewByWeekButtonLabel)
        
        self.viewByWeekButton.frame.origin = CGPoint.zero
        self.viewByWeekButton.frame.size = self.viewByWeekButtonView.frame.size
        self.viewByWeekButton.addTarget(self, action: #selector(DriveTimesViewController.viewByWeekButtonPressed(_:)), for: .touchUpInside)
        self.viewByWeekButtonView.addSubview(self.viewByWeekButton)
        
        let someSchedData = CurrentUser.schedule[2018]
        let someMoreSchedData = CurrentUser.schedule[2017]
        
        print("\n2018: \(someSchedData)\n")
        print("\n2017: \(someMoreSchedData)\n")
        
        
        // display getting started if required
        if CurrentUser.streetAddressA == "" {
            let introVC = self.storyboard!.instantiateViewController(withIdentifier: "GettingStartedViewController") as! GettingStartedViewController
            introVC.transitioningDelegate = self
            self.present(introVC, animated: true, completion: nil)
        }
    }
    
    func setUpNewDriveTimeCard() {
        
    }
    
    func viewByWeekButtonPressed(_ sender: UIButton) {
        print("viewByWeekButtonPressed")
        print(CurrentUser.schedule)
        
    }
    
    func leaveNowButtonPressed(_ sender: UIButton) {
        print("leave now button pressed")
        
        
        
        //let introVC = self.storyboard!.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        let introVC = self.storyboard!.instantiateViewController(withIdentifier: "RoutesViewController") as! RoutesViewController
        introVC.transitioningDelegate = self
        self.present(introVC, animated: true, completion: nil)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("view did scroll")
        //print(scrollView.contentOffset)
        let pageIndex = Int(scrollView.contentOffset.x / self.view.frame.width)
        if pageIndex != self.currentCardIndex {
            print("page Index \(pageIndex)")
            self.currentCardIndex = pageIndex
            
            if self.currentCardIndex == (self.maxCardIndex - 2) {
                let newMaxCardIndex = self.maxCardIndex + self.loadDaysAtATime
                
                // load new cards
                
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

class driveTimeCardView: UIView {
    var cardView = UIView()
    var headerLabel = UILabel()
    var dateLabel = UILabel()
    
    var toWorkLabel = UILabel()
    var toWorkButton = UIButton()
    var backHomeLabel = UILabel()
    var backHomeButton = UIButton()
    var tripSelectBarView = UIView()
    var tripSelectBarWidth: CGFloat = 0.0
    var showingToWork = true
    
    var tripContentView = UIView()
    var twContentView = UIView()
    var bhContentView = UIView()
    var twTripView = TripView()
    var twUnbookedView = UnbookedTripView()
    var bhTripView = TripView()
    var bhUnbookedView = UnbookedTripView()
    
    
    
    func toWorkButtonPressed(_ sender: UIButton) {
        
        self.tripContentView.addSubview(self.twContentView)
        self.twContentView.alpha = 0.0
        if showingToWork == false {
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.toWorkLabel.textColor = UIColor.wrGreen()
                self.backHomeLabel.textColor = UIColor.wrText()
                self.tripSelectBarView.frame.origin.x = self.toWorkLabel.frame.origin.x + ((self.toWorkLabel.frame.width - self.tripSelectBarWidth) / 2)
                self.twContentView.alpha = 1.0
                self.bhContentView.alpha = 0.0
            }, completion: { (finished) in
                self.bhContentView.removeFromSuperview()
                self.showingToWork = true
            })
        }
        
        
    }
    
    func backHomeButtonPressed(_ sender: UIButton) {
        
        self.tripContentView.addSubview(self.bhContentView)
        self.bhContentView.alpha = 0.0
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.backHomeLabel.textColor = UIColor.wrGreen()
            self.toWorkLabel.textColor = UIColor.wrText()
            self.tripSelectBarView.frame.origin.x = self.backHomeLabel.frame.origin.x + ((self.backHomeLabel.frame.width - self.tripSelectBarWidth) / 2)
            self.bhContentView.alpha = 1.0
            self.twContentView.alpha = 0.0
        }, completion: { (finished) in
            self.twContentView.removeFromSuperview()
            self.showingToWork = false
        })
        
        
    }
}

class TripView: UIView {
    var leaveLabel = UILabel()
    var leaveCircleView = UIView()
    var tripLineView = UIView()
    var arriveLabel = UILabel()
    var arriveCircleView = UIView()
    var profileImageViews: [UIImageView] = []
    var loadingImageSpinnerViews : [UIActivityIndicatorView] = []
    var nameLabels: [UILabel] = []
    var timeLabels: [UILabel] = []
}

class UnbookedTripView: UIView {
    var headerLabel = UILabel()
    var descriptorTextView = UITextView()
}


class LeaveNowTripView: UIView {
    var leaveByLabel = UILabel()
    var leaveByTimeLabel = UILabel()
    var leaveBySubLabel = UILabel()
    var leaveButtonView = UIView()
    var leaveButtonLabel = UILabel()
    var leaveButton = UIButton()
}
