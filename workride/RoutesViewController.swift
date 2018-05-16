//
//  RoutesViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-12.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import Firebase
import FirebaseDatabase

class RoutesViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    
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
    
    
    var mapView = GMSMapView()
    let geocoder = GMSGeocoder()
    var userLocationMarker = GMSMarker()
    var legPolyLines : [[GMSPolyline]] = []
    var currentPickupLocation = CLLocationCoordinate2D()
    var currentLocation = CLLocationCoordinate2D()
    var previousLocation = CLLocationCoordinate2D()
    
    let locationManager = CLLocationManager()
    
    let topGradImageView = UIImageView()
    let bottomGradImageView = UIImageView()
    
    let titleLabel = UILabel()
    let titleSubLabel = UILabel()
    
    let closeButtonView = UIView()
    let closeButtonButton = UIButton()
    let closeButtonImageView = UIImageView()
    
    let sideGradImageView = UIImageView()
    
    let bottomInfoView = UIView()
    
    let currentStepDistLabel = UILabel()
    let currentStepDescriptionTextView = UITextView()
    let nextStepDistLabel = UILabel()
    let nextStepDescriptionLabel = UILabel()
    
    let editLocButtonView = UIView()
    let editLocButtonImageView = UIImageView()
    let editLocButtonButton = UIButton()
    var editLocSpinnerView = UIActivityIndicatorView()
    
    let popUpOverlayView = UIView()
    let popUpView = UIView()
    let popUpTitleLabel = UILabel()
    let popUpPaymentLabel = UILabel()
    let popUpPaymentSubLabel = UILabel()
    let popUpOkayLabel = UILabel()
    let popUpOkayButton = UIButton()
    
    var isEditingLocation = false
    var hasArrived = false

    var currentTrip = ScheduleTrip()
    var currentBusiness = Business()
    
    var pickupLocations = [CLLocationCoordinate2D(latitude: 42.27915041895433, longitude: -83.0255913734436), CLLocationCoordinate2D(latitude: 42.293564192170095, longitude: -83.05151224136353)]
    
    var formattedLegsData : [RouteLeg] = []
    var onLegIndex = 0
    var onStepIndex = 0
    var dataLoaded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.wrOffWhite()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let driver = ScheduleRider()
        driver.firstName = CurrentUser.firstName
        /*
        var riders : [ScheduleRider] = []
        var names = ["Matt", "Sarah", "Tim", "Melissa"]
        var deviceIDs = ["dFLX60CY-Hk:APA91bFasOS2eVEqaEFa28IUidA-ATNC_5A-bciZ6VbWRXODeEBlPdpkVIGlBtoryU2eMkPcK5kz0i42yAh9jx3tBQTgNJZC_kJuPjFvVWV3ThYO83peYs4adUWUvvVCggnATr9jCt9K","dFLX60CY-Hk:APA91bFasOS2eVEqaEFa28IUidA-ATNC_5A-bciZ6VbWRXODeEBlPdpkVIGlBtoryU2eMkPcK5kz0i42yAh9jx3tBQTgNJZC_kJuPjFvVWV3ThYO83peYs4adUWUvvVCggnATr9jCt9K","dFLX60CY-Hk:APA91bFasOS2eVEqaEFa28IUidA-ATNC_5A-bciZ6VbWRXODeEBlPdpkVIGlBtoryU2eMkPcK5kz0i42yAh9jx3tBQTgNJZC_kJuPjFvVWV3ThYO83peYs4adUWUvvVCggnATr9jCt9K","dFLX60CY-Hk:APA91bFasOS2eVEqaEFa28IUidA-ATNC_5A-bciZ6VbWRXODeEBlPdpkVIGlBtoryU2eMkPcK5kz0i42yAh9jx3tBQTgNJZC_kJuPjFvVWV3ThYO83peYs4adUWUvvVCggnATr9jCt9K"]
        var leaveTimes = [830, 864, 900, 888]
        for index in 0..<self.pickupLocations.count {
            let newRider = ScheduleRider()
            newRider.firstName = names[index]
            newRider.deviceID = deviceIDs[index]
            newRider.leaveDayTime = leaveTimes[index]
            newRider.pickupLocation = self.pickupLocations[index]
            riders.append(newRider)
        }
        //self.currentTrip.driver = driver
        //self.currentTrip.riders = riders
        */
 
        let todayTimeStamp = makeTimeStamp()
        let todayYear = todayTimeStamp.year
        let todayMonth = todayTimeStamp.month
        let todayDay = todayTimeStamp.day + 1
        let todayDayTime = GetCurrentDayTime()
        
        let currentYearSched = CurrentUser.schedule[todayYear] as! [Int : Any]
        let currentMonthSched = currentYearSched[todayMonth] as! [Int : Any]
        let currentDaySched = currentMonthSched[todayDay] as! [String : ScheduleTrip]
        let toTrip = currentDaySched["to"]
        let fromTrip = currentDaySched["from"]
        
        if todayDayTime >= ((toTrip?.leaveDayTime)! - GlobalParams.beforeTime) && todayDayTime <= ((toTrip?.leaveDayTime)! + GlobalParams.afterTime) {
            self.currentTrip = toTrip!
        } else if todayDayTime >= ((fromTrip?.leaveDayTime)! - GlobalParams.beforeTime) && todayDayTime <= ((fromTrip?.leaveDayTime)! + GlobalParams.afterTime) {
            self.currentTrip = fromTrip!
        } else {
            self.currentTrip = toTrip!
        }
        
        
        for index in 0..<self.currentTrip.riders.count {
            let riderUID = self.currentTrip.riders[index].uid
            self.currentTrip.riders[index].deviceID = ""
            
            let deviceIDRef = Database.database().reference().child("notifications").child("deviceid").child(riderUID).child("token")
            deviceIDRef.observeSingleEvent(of: .value, with: {  (snapshot) in
                if snapshot.exists() {
                    let deviceID = snapshot.value as? String
                    self.currentTrip.riders[index].deviceID = deviceID!
                }
            })
        }
        
        
        self.currentBusiness.location = CurrentUser.business.location //CLLocationCoordinate2D(latitude: 42.2761021502391, longitude: -83.00535678863525)
        
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.smallSideMargin = self.view.frame.width * 0.08
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        
        
        // location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = CLLocationDistance(5.0)
        self.locationManager.activityType = CLActivityType.automotiveNavigation
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        while self.locationManager.location?.coordinate == nil {}
        self.currentLocation = (self.locationManager.location?.coordinate)!
        
        
        
        // set up map
        let center = self.currentLocation
        let mapRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let camera = GMSCameraPosition(target: center, zoom: 15, bearing: 0, viewingAngle: 0)
        let map = GMSMapView.map(withFrame: mapRect, camera: camera)
        self.mapView = map
        
        self.mapView.delegate = self
        // Set the map style by passing the URL of the local file.
        do { if let styleURL = Bundle.main.url(forResource: "Style", withExtension: "json") {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } else {NSLog("Unable to find Style.json")}
        } catch {NSLog("One or more of the map styles failed to load. \(error)")}
        
        self.view.addSubview(self.mapView)
        
        self.currentPickupLocation = center
        
        let driverMarkerImage = UIImage(named: "current-location-marker")
        let driverMarkerImageView = UIImageView(image: driverMarkerImage)
        driverMarkerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
        
        self.userLocationMarker.position = center
        self.userLocationMarker.tracksViewChanges = true
        self.userLocationMarker.iconView = driverMarkerImageView
        self.userLocationMarker.isFlat = true
        self.userLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.userLocationMarker.map = self.mapView
        
        
        
        
        
        // setup side grad
        self.sideGradImageView.image = UIImage(named: "side-grad")
        self.sideGradImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.361, height: self.view.frame.height)
        self.view.addSubview(self.sideGradImageView)
        
        
        
        // setup top grad
        self.topGradImageView.image = UIImage(named: "top-grad")
        self.topGradImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.22)
        self.view.addSubview(self.topGradImageView)
        
        
        // top grad label
        self.titleLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.titleLabel.textColor = UIColor.wrText()
        self.titleLabel.textAlignment = NSTextAlignment.left
        self.titleLabel.text = "pickup \(self.currentTrip.riders[0].firstName)"
        self.titleLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.072, width: standardWidth, height: standardLabelHeight)
        self.view.addSubview(self.titleLabel)
        
        self.titleSubLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.titleSubLabel.textColor = UIColor.wrLightText()
        self.titleSubLabel.textAlignment = NSTextAlignment.left
        self.titleSubLabel.text = "calculating arrive time..."
        self.titleSubLabel.frame = CGRect(x: self.smallSideMargin - self.view.frame.width, y: self.titleLabel.frame.origin.y + self.titleLabel.frame.height, width: standardWidth, height: self.smallLabelHeight)
        self.view.addSubview(self.titleSubLabel)
        
        
        // close button
        /*
        let closeButtonWidth = self.view.frame.width * 0.104
        let closeButtonYPosition = self.titleLabel.frame.origin.y - ((self.titleLabel.frame.height - closeButtonWidth) / 2)
        self.closeButtonView.frame = CGRect(x: self.view.frame.width - self.smallSideMargin - closeButtonWidth, y: self.sideMargin, width: closeButtonWidth, height: closeButtonWidth)
        self.view.addSubview(self.closeButtonView)
        
        self.closeButtonImageView.image = UIImage(named: "close-dark")
        self.closeButtonImageView.frame = CGRect(x: 0, y: 0, width: self.closeButtonView.frame.width, height: self.closeButtonView.frame.height)
        self.closeButtonView.addSubview(self.closeButtonImageView)
        
        self.closeButtonButton.frame = CGRect(x: 0, y: 0, width: self.closeButtonView.frame.width, height: self.closeButtonView.frame.height)
        self.closeButtonButton.addTarget(self, action: #selector(PickupLocationViewController.closeButtonPressed(_:)), for: .touchUpInside)
        self.closeButtonView.addSubview(self.closeButtonButton)
        */
        
        
        
        // set up bottom grad
        let bottomGradHeight = self.view.frame.height * 0.36
        self.bottomInfoView.frame = CGRect(x: 0, y: self.view.frame.height - bottomGradHeight, width: self.view.frame.width, height: bottomGradHeight)
        self.view.addSubview(self.bottomInfoView)
        
        self.bottomGradImageView.image = UIImage(named: "bottom-grad")
        self.bottomGradImageView.frame.origin = CGPoint.zero
        self.bottomGradImageView.frame.size = self.bottomInfoView.frame.size
        self.bottomInfoView.addSubview(self.bottomGradImageView)
        
        let editButtonHeight = self.view.frame.width * 0.184
        self.editLocButtonView.frame = CGRect(x: self.view.frame.width - self.sideMargin - editButtonHeight, y: self.view.frame.height * 0.045, width: editButtonHeight, height: editButtonHeight)
        self.editLocButtonView.backgroundColor = UIColor.wrWhite()
        self.editLocButtonView.layer.borderColor = UIColor.wrGreen().cgColor
        self.editLocButtonView.layer.borderWidth = self.view.frame.width * 0.0107
        self.editLocButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.editLocButtonView.layer.shadowOpacity = 0.7
        self.editLocButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.editLocButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.editLocButtonView.layer.cornerRadius = editButtonHeight / 2
        self.bottomInfoView.addSubview(self.editLocButtonView)
        
        self.editLocButtonImageView.image = UIImage(named: "turn-right")
        self.editLocButtonImageView.frame.origin = CGPoint.zero
        self.editLocButtonImageView.frame.size = self.editLocButtonView.frame.size
        self.editLocButtonView.addSubview(self.editLocButtonImageView)
        
        self.editLocButtonButton.frame.size = self.editLocButtonView.frame.size
        self.editLocButtonButton.frame.origin = CGPoint.zero
        self.editLocButtonButton.addTarget(self, action: #selector(PickupLocationViewController.editLocButtonPressed(_:)), for: .touchUpInside)
        self.editLocButtonView.addSubview(self.editLocButtonButton)
        
        let suSpinnerViewHeight = self.view.frame.height * 0.112
        self.editLocSpinnerView.frame = CGRect(x: (self.editLocButtonView.frame.width - suSpinnerViewHeight) / 2, y: (self.editLocButtonView.frame.height - suSpinnerViewHeight) / 2, width: suSpinnerViewHeight, height: suSpinnerViewHeight)
        self.editLocSpinnerView.color = UIColor.wrGreen()
        self.editLocSpinnerView.hidesWhenStopped = true
        self.editLocButtonView.addSubview(self.editLocSpinnerView)
        
        self.currentStepDistLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.currentStepDistLabel.textColor = UIColor.wrText()
        self.currentStepDistLabel.textAlignment = NSTextAlignment.left
        self.currentStepDistLabel.text = "0.0 km"
        self.currentStepDistLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.106, width: standardWidth, height: standardLabelHeight)
        self.bottomInfoView.addSubview(self.currentStepDistLabel)
        
        self.currentStepDescriptionTextView.font = getFont(0, screenHeight: self.view.frame.height)
        self.currentStepDescriptionTextView.textColor = UIColor.wrText()
        self.currentStepDescriptionTextView.backgroundColor = UIColor.clear
        self.currentStepDescriptionTextView.textAlignment = NSTextAlignment.left
        self.currentStepDescriptionTextView.text = "turn right onto Maxon Ave and then heres some more words."
        self.currentStepDescriptionTextView.isScrollEnabled = false
        self.currentStepDescriptionTextView.isEditable = false
        self.currentStepDescriptionTextView.isSelectable = false
        self.currentStepDescriptionTextView.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0)
        self.currentStepDescriptionTextView.frame.origin = CGPoint(x: self.smallSideMargin, y: self.editLocButtonView.frame.origin.y + self.editLocButtonView.frame.height)
        
        self.currentStepDescriptionTextView.frame.size = CGSize(width: self.standardWidth, height: self.bottomInfoView.frame.height - self.currentStepDescriptionTextView.frame.origin.y)
        self.bottomInfoView.addSubview(self.currentStepDescriptionTextView)
        
        /*
        self.nextStepDistLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.nextStepDistLabel.textColor = UIColor.wrText().withAlphaComponent(0.3)
        self.nextStepDistLabel.textAlignment = NSTextAlignment.left
        self.nextStepDistLabel.text = "0.0 km"
        self.nextStepDistLabel.frame = CGRect(x: self.smallSideMargin, y: self.currentStepDescriptionTextView.frame.origin.y + self.currentStepDescriptionTextView.frame.height, width: standardWidth, height: standardLabelHeight)
        self.bottomInfoView.addSubview(self.nextStepDistLabel)
        
        self.nextStepDescriptionLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.nextStepDescriptionLabel.textColor = UIColor.wrText().withAlphaComponent(0.3)
        self.nextStepDescriptionLabel.textAlignment = NSTextAlignment.left
        self.nextStepDescriptionLabel.text = "words and words and werds."
        self.nextStepDescriptionLabel.frame = CGRect(x: self.smallSideMargin, y: self.nextStepDistLabel.frame.origin.y + (self.nextStepDistLabel.frame.height * 0.8), width: self.standardWidth, height: self.smallLabelHeight)
        self.bottomInfoView.addSubview(self.nextStepDescriptionLabel)
        */
        
        let markerImage = UIImage(named: "location-marker")
        let markerImageView = UIImageView(image: markerImage)
        markerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
        
        
        self.editLocSpinnerView.startAnimating()
        self.editLocButtonImageView.isHidden = true
        // AIzaSyDsjUMhbj7VRRHGDbf3XWIyfjaPkGodmSk
        var wayPointString = ""
        for index in 0..<self.currentTrip.riders.count {
            wayPointString += "\(self.currentTrip.riders[index].pickupLocation.latitude),\(self.currentTrip.riders[index].pickupLocation.longitude)"
            if index != (self.pickupLocations.count - 1) { wayPointString += "%7C" }
        }
        
        let sendURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.currentLocation.latitude),\(self.currentLocation.longitude)&waypoints=optimize:true%7C\(wayPointString)&destination=\(self.currentBusiness.location.latitude),\(self.currentBusiness.location.longitude)&key=AIzaSyDsjUMhbj7VRRHGDbf3XWIyfjaPkGodmSk"
        
        let manager = AFHTTPSessionManager()
        manager.post(sendURL, parameters: nil, success: { (operation, responseObject) -> Void in
            if let response = responseObject as? [String : Any] {
                print("\nresponse:\n\(response)")
                self.plotRouteData(returnedData: response)
                
                // set dist label and description label
                if self.formattedLegsData[0].steps.count > 1 {
                    self.currentStepDistLabel.text = self.formattedLegsData[0].steps[0].distanceText
                    self.currentStepDescriptionTextView.text = self.formattedLegsData[0].steps[1].htmlInstructionsFormatted
                    
                    if self.formattedLegsData[0].steps[1].maneuver == "turn-left" || self.formattedLegsData[0].steps[1].maneuver == "turn-right" {
                        self.editLocButtonImageView.image = UIImage(named: self.formattedLegsData[0].steps[1].maneuver)
                    } else {
                        self.editLocButtonImageView.image = UIImage(named: "go-straight")
                    }
                } else {
                    self.currentStepDistLabel.text = self.formattedLegsData[0].steps[0].distanceText
                    self.currentStepDescriptionTextView.text = self.formattedLegsData[0].steps[0].htmlInstructionsFormatted
                    self.editLocButtonImageView.image = UIImage(named: "arrive")
                }
                
                
                self.dataLoaded = true
                
                
                
                /*
                if self.formattedLegsData[0].steps.count > 1 {
                    self.currentStepDistLabel.text = self.formattedLegsData[0].steps[1].distanceText
                    self.currentStepDescriptionTextView.text = self.formattedLegsData[0].steps[1].htmlInstructionsFormatted
                } else {
                    self.currentStepDistLabel.text = "Arrive"
                    self.currentStepDescriptionTextView.text = "arrive to pick up \(self.formattedLegsData[0].pickupName)"
                }
                
                if self.formattedLegsData[0].steps[1].maneuver == "turn-left" || self.formattedLegsData[0].steps[1].maneuver == "turn-right" {
                    self.editLocButtonImageView.image = UIImage(named: self.formattedLegsData[0].steps[0].maneuver)
                } else {
                    self.editLocButtonImageView.image = UIImage(named: "go-straight")
                }
                self.dataLoaded = true
                self.onStepIndex = 1
                */
                
                
                
                
                // notifiy riders that driver is leaving
                let nowTimeStamp = makeTimeStamp()
                let currentHour = nowTimeStamp.hour
                let currentMin = nowTimeStamp.minute
                let currentDayTime = (currentHour * 60) + currentMin
                
                for index in 0..<self.currentTrip.riders.count {
                    let timeDif = self.currentTrip.riders[index].leaveDayTime - currentDayTime
                    var timeString = "\(timeDif) mins"
                    if timeDif >= 60 {
                        timeString = "\(Int(timeDif / 60)) hour and \(timeDif % 60) mins"
                    }
                    
                    self.notifyRider(withLegIndex: index, title: "\(CurrentUser.firstName) is leaving", body: "Your ride to work will arrive in about \(timeString)")
                    self.currentTrip.riders[index].hasBeenNotified = false
                }
                self.editLocSpinnerView.stopAnimating()
                self.editLocButtonImageView.isHidden = false
                
                self.printLegsData()
            }
            
        }) { (operation, error) -> Void in
            print("failure operation:\n\(String(describing: operation))")
            print("\nerror:\n\(error)")
        }
        
        
        
        
        
        // finished pop up
        /*
        let popUpOverlayView = UIView()
        let popUpView = UIView()
        let popUpTitleLabel = UILabel()
        let popUpPaymentLabel = UILabel()
        let popUpPaymentSubLabel = UILabel()
        let popUpOkayLabel = UILabel()
        let popUpOkayButton = UIButton()
        */
        
        self.popUpOverlayView.frame = self.view.frame
        self.popUpOverlayView.backgroundColor = UIColor.wrText().withAlphaComponent(0.7)
        //self.view.addSubview(self.popUpOverlayView)
        
        
        
        
        let cardHeight = self.view.frame.height / 3
        self.popUpView.frame = CGRect(x: self.smallSideMargin / 2, y: (self.view.frame.height - cardHeight) / 2, width: self.view.frame.width - (self.smallSideMargin), height: cardHeight)
        self.popUpView.layer.cornerRadius = self.view.frame.width * 0.036
        self.popUpView.layer.shadowColor = UIColor.black.cgColor
        self.popUpView.layer.shadowRadius = self.view.frame.width * 0.024
        self.popUpView.layer.shadowOpacity = 0.33
        self.popUpView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.popUpView.backgroundColor = UIColor.wrWhite()
        //self.view.addSubview(self.popUpView)
        
        self.popUpTitleLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.popUpTitleLabel.textColor = UIColor.wrText()
        self.popUpTitleLabel.textAlignment = NSTextAlignment.left
        self.popUpTitleLabel.text = "arrived"
        self.popUpTitleLabel.frame = CGRect(x: self.smallSideMargin * 0.6, y: self.smallSideMargin * 0.6, width: standardWidth, height: standardLabelHeight)
        self.popUpView.addSubview(self.popUpTitleLabel)
        
        
        
        var paymentAmmount = 0
        for index in 0..<self.currentTrip.riders.count {
            let riderPayment = self.currentTrip.riders[index].fare
            paymentAmmount += riderPayment
        }
        var paymentString = GetMoneyString(paymentAmmount)
        self.popUpPaymentLabel.font = getFont(4, screenHeight: self.view.frame.height)
        self.popUpPaymentLabel.textColor = UIColor.wrText()
        self.popUpPaymentLabel.textAlignment = NSTextAlignment.center
        self.popUpPaymentLabel.text = paymentString
        self.popUpPaymentLabel.frame = CGRect(x: self.smallSideMargin, y: self.popUpTitleLabel.frame.origin.y + (self.popUpTitleLabel.frame.height * 1.5), width: self.standardWidth, height: self.standardLabelHeight * self.goldenRatio)
        self.popUpView.addSubview(self.popUpPaymentLabel)
        
        self.popUpPaymentSubLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.popUpPaymentSubLabel.textColor = UIColor.wrLightText()
        self.popUpPaymentSubLabel.textAlignment = NSTextAlignment.center
        self.popUpPaymentSubLabel.text = "your ride payment"
        self.popUpPaymentSubLabel.frame = CGRect(x: self.smallSideMargin, y: self.popUpPaymentLabel.frame.origin.y + self.popUpPaymentLabel.frame.height, width: self.standardWidth, height: self.standardLabelHeight)
        self.popUpView.addSubview(self.popUpPaymentSubLabel)
        
        self.popUpOkayLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.popUpOkayLabel.textColor = UIColor.wrGreen()
        self.popUpOkayLabel.textAlignment = NSTextAlignment.center
        self.popUpOkayLabel.text = "okay"
        self.popUpOkayLabel.frame = CGRect(x: self.smallSideMargin, y: self.popUpView.frame.height - self.standardLabelHeight - (self.smallSideMargin / 2), width: self.standardWidth, height: self.standardLabelHeight)
        self.popUpView.addSubview(self.popUpOkayLabel)
        
        self.popUpOkayButton.frame = self.popUpOkayLabel.frame
        self.popUpOkayButton.addTarget(self, action: #selector(RoutesViewController.okayPopUpButtonPressed(_:)), for: .touchUpInside)
        self.popUpView.addSubview(self.popUpOkayButton)
    }
    
    func closeButtonPressed(_ sender: UIButton) {
        print("closeButtonPressed")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func okayPopUpButtonPressed(_ sender: UIButton) {
        print("okayPopUpButtonPressed")
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.popUpOverlayView.alpha = 0.0
            self.popUpView.alpha = 0.0
        }, completion: { (finished) in
            
            UIView.animate(withDuration: 0.0, delay: 0.3, options: .curveEaseInOut, animations: {
                
            }, completion: { (finished) in
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        })
        
    }
    
    func editLocButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        print("editLocButtonPressed")
        
        self.moveToNextStep()
        //self.reloadRoute()
        sender.isEnabled = true
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //mapView.clear()
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if self.isEditingLocation {
            self.userLocationMarker.position = position.target
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        
    }
    
    func plotRouteData(returnedData: [String : Any]) {
        /*
        formattedLegsData = [["distance":["text":"","value":0],"duration":["text":"","value":0],"end_location":[lat,lng],"start_location":[lat,lng],
                              "steps":[
                                    ["distance":["text":"","value":0],
                                     "duration":["text":"","value":0],
                                     "end_location":[lat,lng],
                                     "start_location":[lat,lng],
                                     "html_instructions":"",
                                     "polyline":["points"=""],
                                     "maneuver":""
                                    ]
                                ]
                            ]
                        ]
        */
        
        let markerImage = UIImage(named: "location-marker")
        let markerImageView = UIImageView(image: markerImage)
        markerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
        
        
        let routesData = returnedData["routes"] as! NSArray
        let usedRouteData = routesData[0] as! [String : Any]
        let legsData = usedRouteData["legs"] as! NSArray
        
        let waypointOrderData = usedRouteData["waypoint_order"] as! NSArray
        
        for legsIndex in 0..<legsData.count {
            let currentLegData = legsData[legsIndex] as! [String : Any]
            
            // leg data
            let newLeg = RouteLeg()
            let currentLegDistanceData = currentLegData["distance"] as! [String : Any]
            newLeg.distanceVal = currentLegDistanceData["value"] as! Int
            newLeg.distanceText = currentLegDistanceData["text"] as! String
            let currentLegDurationData = currentLegData["duration"] as! [String : Any]
            newLeg.durationVal = currentLegDurationData["value"] as! Int
            newLeg.durationText = currentLegDurationData["text"] as! String
            let currentLegEndLocData = currentLegData["end_location"] as! [String : Any]
            newLeg.endLocation.latitude = CLLocationDegrees(currentLegEndLocData["lat"] as! Float)
            newLeg.endLocation.longitude = CLLocationDegrees(currentLegEndLocData["lng"] as! Float)
            let currentLegStartLocData = currentLegData["start_location"] as! [String : Any]
            newLeg.startLocation.latitude = CLLocationDegrees(currentLegStartLocData["lat"] as! Float)
            newLeg.startLocation.longitude = CLLocationDegrees(currentLegStartLocData["lng"] as! Float)
            
            
            let wayPointMarker = GMSMarker()
            wayPointMarker.tracksViewChanges = true
            wayPointMarker.iconView = markerImageView
            wayPointMarker.isFlat = false
            wayPointMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            wayPointMarker.map = self.mapView
            
            if legsIndex < waypointOrderData.count {
                if waypointOrderData.count > 0 {
                    let currentWaypointIndex = waypointOrderData[legsIndex] as! Int
                    newLeg.pickupName = self.currentTrip.riders[currentWaypointIndex].firstName
                    newLeg.waypointIndex = currentWaypointIndex
                }
                wayPointMarker.position = self.currentTrip.riders[newLeg.waypointIndex].pickupLocation
                wayPointMarker.title = self.currentTrip.riders[newLeg.waypointIndex].firstName
            } else {
                wayPointMarker.position = self.currentBusiness.location
                wayPointMarker.title = self.currentBusiness.name
            }
            
            newLeg.endMarker = wayPointMarker
            
            
            // steps data
            let stepsData = currentLegData["steps"] as! NSArray
            
            //var stepCoords : [CLLocationCoordinate2D] = []
            //var snapToRoadsParams = ""
            var currentLegPolylines : [GMSPolyline] = []
            
            for stepsIndex in 0..<stepsData.count {
                let newStep = RouteStep()
                
                let currentStepsData = stepsData[stepsIndex] as! [String : Any]
                
                let currentStepDistanceData = currentStepsData["distance"] as! [String : Any]
                newStep.distanceVal = currentStepDistanceData["value"] as! Int
                newStep.distanceText = currentStepDistanceData["text"] as! String
                let currentStepDurationData = currentStepsData["duration"] as! [String : Any]
                newStep.durationVal = currentStepDurationData["value"] as! Int
                newStep.durationText = currentStepDurationData["text"] as! String
                let currentStepEndLocData = currentStepsData["end_location"] as! [String : Any]
                newStep.endLocation.latitude = CLLocationDegrees(currentStepEndLocData["lat"] as! Float)
                newStep.endLocation.longitude = CLLocationDegrees(currentStepEndLocData["lng"] as! Float)
                let currentStepStartLocData = currentStepsData["start_location"] as! [String : Any]
                newStep.startLocation.latitude = CLLocationDegrees(currentStepStartLocData["lat"] as! Float)
                newStep.startLocation.longitude = CLLocationDegrees(currentStepStartLocData["lng"] as! Float)
                
                newStep.htmlInstructionsRaw = currentStepsData["html_instructions"] as! String
                newStep.formatHTMLInstructions()
                let maneuverDataExists = currentStepsData["maneuver"]
                if maneuverDataExists != nil {
                    newStep.maneuver = currentStepsData["maneuver"] as! String
                    
                }
                
                /*
                let newMarker = GMSMarker()
                newMarker.tracksViewChanges = true
                if stepsIndex == (stepsData.count - 1) { newMarker.iconView = markerImageView }
                newMarker.isFlat = false
                newMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                newMarker.map = self.mapView
                newMarker.position = newStep.endLocation
                newMarker.title = "leg \(legsIndex), step \(stepsIndex)"
                newMarker.snippet = newStep.htmlInstructionsFormatted
                */
                /*
                if stepsIndex == 0 {
                    stepCoords.append(newStep.startLocation)
                    snapToRoadsParams += (newStep.startLocation.latitude.description + "," + newStep.startLocation.longitude.description + "%7C")
                }
                
                stepCoords.append(newStep.endLocation)
                snapToRoadsParams += (newStep.endLocation.latitude.description + "," + newStep.endLocation.longitude.description)
                if stepsIndex != (stepsData.count - 1) {
                    snapToRoadsParams += "%7C"
                }
                */
                
                
                let polyLineData = currentStepsData["polyline"] as! [String : Any]
                let pointsData = polyLineData["points"] as! String
                let newPolyline = GMSPath.init(fromEncodedPath: pointsData)
                let polyline = GMSPolyline(path: newPolyline)
                
                if legsIndex == 0 { polyline.strokeColor = UIColor.wrGreen() } else { polyline.strokeColor = UIColor.wrLightText() }
                polyline.strokeWidth = 3.0
                newStep.polyline = polyline
                newLeg.steps.append(newStep)
            }
            self.legPolyLines.append(currentLegPolylines)
            self.formattedLegsData.append(newLeg)
            
            /*
            print("snapToRoadsParams = \(snapToRoadsParams)")
            
            let rawUrlStr = "https://roads.googleapis.com/v1/snapToRoads?path=\(snapToRoadsParams)&interpolate=true&key=AIzaSyDsjUMhbj7VRRHGDbf3XWIyfjaPkGodmSk"
            
            let manager = AFHTTPSessionManager()
            
            manager.post(rawUrlStr, parameters: nil, success: { (operation, responseObject) -> Void in
                if let response = responseObject as? [String : Any] {
                    print("\nresponse:\n\(response)")
                    
                    let path = GMSMutablePath()
                    //path.add(CLLocationCoordinate2D(latitude: -33.85, longitude: 151.20))
                    //path.add(CLLocationCoordinate2D(latitude: -33.70, longitude: 151.40))
                    //path.add(CLLocationCoordinate2D(latitude: -33.73, longitude: 151.41))
                    
                    
                    let snappedPointsData = response["snappedPoints"] as! NSArray
                    for pointIndex in 0..<snappedPointsData.count {
                        let currentPointData = snappedPointsData[pointIndex] as! [String : Any]
                        let currentLocationData = currentPointData["location"] as! [String : Any]
                        let currentLat = currentLocationData["latitude"] as! Double
                        let currentLng = currentLocationData["longitude"] as! Double
                        let currentLoc = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLng)
                        path.add(currentLoc)
                    }
                    
                    
                    
                    
                }
                
            }) { (operation, error) -> Void in
                print("failure operation:\n\(operation)")
                print("\nerror:\n\(error)")
            }
            
            */
        }
        
        for l in 0..<self.formattedLegsData.count {
            let legIndex = self.formattedLegsData.count - 1 - l
            for s in 0..<self.formattedLegsData[legIndex].steps.count {
                self.formattedLegsData[legIndex].steps[s].polyline.map = self.mapView
            }
        }
    }
    
    
    let zooms = [15, 16, 17]
    let zoomDists = [600.0, 300.0, 150.0]
    var updatesOffPath = 0
    let maxUpdatesOffPath = 5
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations.last
        self.currentLocation = (location?.coordinate)!
        self.userLocationMarker.position = self.currentLocation
        
        
        let newHeading = GMSGeometryHeading(self.previousLocation, self.currentLocation)
        print("pLoc = \(self.previousLocation), cLoc = \(self.currentLocation)")
        print("newHeading = \(newHeading)")
        
        
        if self.dataLoaded {
            let endOfStepLocation = self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].endLocation
            let distanceFromEndOfStep = GetDistance(self.currentLocation, locationB: endOfStepLocation)
            
            
            var zoom = 15
            for index in 0..<self.zooms.count {
                if distanceFromEndOfStep < zoomDists[index] { zoom = zooms[index] }
            }
            self.mapView.camera = GMSCameraPosition(target: self.currentLocation, zoom: Float(zoom), bearing: newHeading, viewingAngle: 0)
            
            
            let isOnPath = GMSGeometryIsLocationOnPathTolerance(self.currentLocation, self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].polyline.path!, true, CLLocationDistance(15.0))
            if isOnPath == false {
                self.updatesOffPath += 1
            } else {
                self.updatesOffPath = 0
            }
            
            if self.updatesOffPath == self.maxUpdatesOffPath {
                self.reloadRoute()
                self.updatesOffPath = 0
            }
            
            if distanceFromEndOfStep <= 36.0 {
                self.moveToNextStep()
            } else {
                let distString = self.getDistanceString(distanceFromEndOfStep)
                
                if self.dataLoaded {
                    let stepsInLeg = self.formattedLegsData[self.onLegIndex].steps.count
                    if self.onStepIndex == (stepsInLeg - 1) {
                        self.currentStepDistLabel.text = "Arrive in \(distString)"
                        self.currentStepDescriptionTextView.text = self.formattedLegsData[self.onLegIndex].pickupName
                    } else {
                        self.currentStepDistLabel.text = distString
                        self.currentStepDescriptionTextView.text = self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].htmlInstructionsFormatted
                    }
                    
                    // check if user went another way and completed leg
                    print("608 self.onLegIndex = \(self.onLegIndex)")
                
                    let endOfLegLocation = self.formattedLegsData[self.onLegIndex].endLocation
                    let distanceFromEndOfLeg = GetDistance(self.currentLocation, locationB: endOfLegLocation)
                    if distanceFromEndOfLeg <= 200 {
                        self.notifyRider(withLegIndex: self.onLegIndex, title: "Your ride has arrived", body: "\(CurrentUser.firstName) has arrived to take you to work.")
                    }
                }
            }
        } else {
            self.mapView.camera = GMSCameraPosition(target: self.currentLocation, zoom: 15, bearing: 0, viewingAngle: 0)
        }
        self.previousLocation = self.currentLocation
 
    }
    
    
    
    
    func moveToNextStep() {
        print("moving with leg index = \(self.onLegIndex), step index = \(self.onStepIndex)")
        let stepsInLeg = self.formattedLegsData[self.onLegIndex].steps.count
        
        // check if steps remain in leg
        if self.onStepIndex == (stepsInLeg - 1) {
            // no steps remain in leg - move to next leg if possible
            
            // check if more legs exist
            if self.onLegIndex == (self.formattedLegsData.count - 1) && self.hasArrived == false {
                // no more legs exist
                self.hasArrived = true
                /*
                self.currentStepDistLabel.text = "Done"
                self.currentStepDescriptionTextView.text = "You have arrived at work. Have a good shift."
                self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].polyline.map = nil
                self.editLocButtonImageView.image = UIImage(named: "arrive")
                */
                
                
                self.view.addSubview(self.popUpOverlayView)
                self.view.addSubview(self.popUpView)
                self.popUpOverlayView.alpha = 0.0
                self.popUpView.alpha = 0.0
                UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.popUpOverlayView.alpha = 1.0
                    self.popUpView.alpha = 1.0
                }, completion: { (finished) in
                    
                })
                
                
            } else {
                // more legs exist - move to next
                
                // remove last step polyline from previous leg
                self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].polyline.map = nil
                
                // remove pickup location marker
                self.formattedLegsData[self.onLegIndex].endMarker.map = nil
                
                // change title
                self.titleLabel.text = "pick up \(self.formattedLegsData[self.onLegIndex + 1].pickupName)"
                
                if self.formattedLegsData[self.onLegIndex + 1].steps.count > 1 {
                    self.currentStepDistLabel.text = self.formattedLegsData[self.onLegIndex + 1].steps[0].distanceText
                    self.currentStepDescriptionTextView.text = self.formattedLegsData[self.onLegIndex + 1].steps[1].htmlInstructionsFormatted
                    
                    if self.formattedLegsData[self.onLegIndex + 1].steps[1].maneuver == "turn-left" || self.formattedLegsData[self.onLegIndex + 1].steps[1].maneuver == "turn-right" {
                        self.editLocButtonImageView.image = UIImage(named: self.formattedLegsData[self.onLegIndex + 1].steps[1].maneuver)
                    } else {
                        self.editLocButtonImageView.image = UIImage(named: "go-straight")
                    }
                }
                
                // turn next leg polylines green
                for index in 0..<self.formattedLegsData[self.onLegIndex + 1].steps.count {
                    self.formattedLegsData[self.onLegIndex + 1].steps[index].polyline.strokeColor = UIColor.wrGreen()
                }
                
                // set current rider status to picked up
                let currentWaypointIndex = self.formattedLegsData[self.onLegIndex].waypointIndex
                self.currentTrip.riders[currentWaypointIndex].hasArrived = true
                
                
                self.onLegIndex += 1
                self.onStepIndex = 0
                
                
            }
        } else {
            // steps remain in leg - move to next step
            
            // check if step will be moving to last step in leg
            if self.onStepIndex == (stepsInLeg - 2) {
                // moving to last step of leg
                
                self.currentStepDistLabel.text = self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex + 1].distanceText
                self.currentStepDescriptionTextView.text = "Arrive to pick up \(self.formattedLegsData[self.onLegIndex].pickupName)"
                self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].polyline.map = nil
                self.editLocButtonImageView.image = UIImage(named: "arrive")
                
            } else {
                // moving to next step (not last step of leg)
                
                self.currentStepDistLabel.text = self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex + 1].distanceText
                self.currentStepDescriptionTextView.text = self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex + 2].htmlInstructionsFormatted
                self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex].polyline.map = nil
                if self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex + 2].maneuver == "turn-left" || self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex + 2].maneuver == "turn-right" {
                    self.editLocButtonImageView.image = UIImage(named: self.formattedLegsData[self.onLegIndex].steps[self.onStepIndex + 2].maneuver)
                } else {
                    self.editLocButtonImageView.image = UIImage(named: "go-straight")
                }
                
            }
            
            self.onStepIndex += 1
        }
        
        print("finished moving with leg index = \(self.onLegIndex), step index = \(self.onStepIndex)")
    }
    
    
    
    
    func getDistanceString(_ distance: Double) -> String {
        if distance < 1000 {
            let distInt = Int(distance)
            return "\(distInt) m"
        } else {
            let tempVal = distance / 100
            let tempInt = Int(tempVal)
            let truncatedVal = Float(tempInt) / 10.0
            return "\(truncatedVal.description) km"
        }
    }
    
    
    func notifyRider(withLegIndex : Int, title : String, body: String) {
        
        if withLegIndex < self.currentTrip.riders.count {
            
            let waypointIndex = self.formattedLegsData[withLegIndex].waypointIndex
            let riderDeviceID = self.currentTrip.riders[waypointIndex].deviceID
            
            if self.currentTrip.riders[waypointIndex].hasBeenNotified == false {
                print("notify rider with leg index = \(withLegIndex)")
                print("waypoint index = \(waypointIndex)\nrider device token id = \(riderDeviceID)")
                let URL = "https://fcm.googleapis.com/fcm/send"
                let notificationParams = ["title" : title, "body" : body, "sound" : "notification-audio.m4a"]
                let params = ["notification" : notificationParams, "to" : riderDeviceID] as [String : Any]
                
                let request = NSMutableURLRequest(url: NSURL(string: URL) as! URL)
                request.httpMethod = "POST"
                
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                } catch {
                    print("error")
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("key=AAAA-caVPUY:APA91bErHyaK7QRcquI5JwSzxDU6SGTABhTrWCkJlhb5IupHVdmyYNknbTinD2lbob2SsvI0QLhZOoFpO4Uye6XSyUnOaOK5-qZhN0QifROXpm2cU9EKWXfS7XQXErPyjvQpK9BLLR0R", forHTTPHeaderField: "Authorization")
                
                print(request.allHTTPHeaderFields ?? "request.allHTTPHeaderFields not found")
                
                URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                    
                    let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print(result)
                    self.currentTrip.riders[waypointIndex].hasBeenNotified = true
                    
                }).resume()
            }
        }
    }
    
    func reloadRoute() {
        print("reloading route")
        self.editLocSpinnerView.startAnimating()
        self.editLocButtonImageView.isHidden = true
        self.dataLoaded = false
        self.currentStepDistLabel.text = "reloading..."
        self.currentStepDescriptionTextView.text = "one moment as your route recalculates"
        
        
        for i in 0..<self.formattedLegsData.count {
            self.formattedLegsData[i].endMarker.map = nil
            for j in 0..<self.formattedLegsData[i].steps.count {
                self.formattedLegsData[i].steps[j].polyline.map = nil
            }
        }
        self.formattedLegsData.removeAll()
        
        
        let markerImage = UIImage(named: "location-marker")
        let markerImageView = UIImageView(image: markerImage)
        markerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
        
        
        
        // AIzaSyDsjUMhbj7VRRHGDbf3XWIyfjaPkGodmSk
        var wayPointString = ""
        var numberOfRemainingWaypoints = 0
        for index in 0..<self.currentTrip.riders.count {
            if self.currentTrip.riders[index].hasArrived == false {
                numberOfRemainingWaypoints += 1
            }
        }
        
        for index in 0..<self.currentTrip.riders.count {
            if self.currentTrip.riders[index].hasArrived == false {
                wayPointString += "\(self.currentTrip.riders[index].pickupLocation.latitude),\(self.currentTrip.riders[index].pickupLocation.longitude)"
                if index != (numberOfRemainingWaypoints - 1) { wayPointString += "%7C" }
            }
        }
        
        let sendURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.currentLocation.latitude),\(self.currentLocation.longitude)&waypoints=optimize:true%7C\(wayPointString)&destination=\(self.currentBusiness.location.latitude),\(self.currentBusiness.location.longitude)&key=AIzaSyDsjUMhbj7VRRHGDbf3XWIyfjaPkGodmSk"
        
        let manager = AFHTTPSessionManager()
        manager.post(sendURL, parameters: nil, success: { (operation, responseObject) -> Void in
            if let response = responseObject as? [String : Any] {
                print("\nresponse:\n\(response)")
                self.plotRouteData(returnedData: response)
                
                // set dist label and description label
                if self.formattedLegsData[0].steps.count > 1 {
                    self.currentStepDistLabel.text = self.formattedLegsData[0].steps[0].distanceText
                    self.currentStepDescriptionTextView.text = self.formattedLegsData[0].steps[1].htmlInstructionsFormatted
                    
                    if self.formattedLegsData[0].steps[1].maneuver == "turn-left" || self.formattedLegsData[0].steps[1].maneuver == "turn-right" {
                        self.editLocButtonImageView.image = UIImage(named: self.formattedLegsData[0].steps[1].maneuver)
                    } else {
                        self.editLocButtonImageView.image = UIImage(named: "go-straight")
                    }
                } else {
                    self.currentStepDistLabel.text = self.formattedLegsData[0].steps[0].distanceText
                    self.currentStepDescriptionTextView.text = self.formattedLegsData[0].steps[0].htmlInstructionsFormatted
                    self.editLocButtonImageView.image = UIImage(named: "arrive")
                }
                
                
                self.dataLoaded = true
 
 
                self.onLegIndex = 0
                self.onStepIndex = 0
                
                
                
                
                self.editLocSpinnerView.stopAnimating()
                self.editLocButtonImageView.isHidden = false
                
                self.printLegsData()
                
                
            }
            
        }) { (operation, error) -> Void in
            print("failure operation:\n\(String(describing: operation))")
            print("\nerror:\n\(error)")
        }
    }
    
    func printLegsData() {
        print("formatted legs data = ")
        for i in 0..<self.formattedLegsData.count {
            print("   leg \(i) : {")
            print("      startLocation = \(self.formattedLegsData[i].startLocation)")
            print("      endLocation = \(self.formattedLegsData[i].endLocation)")
            print("      waypoint index = \(self.formattedLegsData[i].waypointIndex)")
            print("      pickup name = \(self.formattedLegsData[i].pickupName)")
            print("      steps : [")
            
            for j in 0..<self.formattedLegsData[i].steps.count {
                print("       \(j):{")
                print("            startLocation = \(self.formattedLegsData[i].steps[j].startLocation)")
                print("            endLocation = \(self.formattedLegsData[i].steps[j].endLocation)")
                print("            waypoint index = \(self.formattedLegsData[i].steps[j].htmlInstructionsFormatted)")
                print("            pickup name = \(self.formattedLegsData[i].steps[j].distanceText)")
                print("         },")
            }
            
            print("      ]")
            print("   },")
        }
    }
}

class RouteLeg {
    var distanceVal : Int = 0
    var distanceText = ""
    var durationVal : Int = 0
    var durationText = ""
    var endLocation = CLLocationCoordinate2D()
    var startLocation = CLLocationCoordinate2D()
    var pickupName = ""
    var waypointIndex = 0
    var endMarker = GMSMarker()
    var hasArrived = false
    
    var steps : [RouteStep] = []
}

class RouteStep {
    var distanceVal : Int = 0
    var distanceText = ""
    var durationVal : Int = 0
    var durationText = ""
    var endLocation = CLLocationCoordinate2D()
    var startLocation = CLLocationCoordinate2D()
    var htmlInstructionsRaw = ""
    var htmlInstructionsFormatted = ""
    var encodedPolyline = ""
    var polyline = GMSPolyline()
    var maneuver = ""
    
    func formatHTMLInstructions() {
        let charArray = Array(self.htmlInstructionsRaw.characters)
        
        var skippingChars = false
        for index in 0..<charArray.count {
            if skippingChars {
                if charArray[index] == ">" {
                    skippingChars = false
                }
            } else {
                if charArray[index] != "<" {
                    self.htmlInstructionsFormatted += charArray[index].description
                } else {
                    skippingChars = true
                }
            }
        }
    }
}



