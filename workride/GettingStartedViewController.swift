//
//  GettingStartedViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-26.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import Firebase
import FirebaseDatabase

class GettingStartedViewController: UIViewController, UIViewControllerTransitioningDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    //important constant definitions
    let goldenRatio : CGFloat = 1.61803398875
    let textExtraSpaceFactor : CGFloat = 1.25
    var standardLabelHeight: CGFloat = 0.0
    var smallLabelHeight: CGFloat = 0.0
    var sideMargin: CGFloat = 0.0
    var standardWidth: CGFloat = 0.0
    
    
    var pageViews : [UIView] = []
    var titleLabelText : [String] = ["getting started", "set your schedule", "setup payment", "my address"]
    var imageNamesDriver = ["GS-D-0","GS-D-1","GS-D-2"]
    var imageNamesRider = ["GS-R-0","GS-R-1","GS-R-2"]
    var descriptorTextDriver = ["drive time cards will show you when your ride will arrive.","you can set your work times on the schedule page. This allows you to be matched with drivers that have similar schedules as you.","in order for ride payments to process, you'll need to fill in your payment information on your profile.",""]
    var descriptorTextRider = ["drive time cards will show you when your ride will arrive.","you can set your work times on the schedule page. This allows you to be matched with drivers that have similar schedules as you.","in order for ride payments to process, you'll need to fill in your payment information on your profile.",""]
    var descriptorTextFieldHeights : [CGFloat] = [0.1,0.16,0.13,0.1]
    
    let scrollImagesSelectedDot = UIView()
    var scrollImagesUnselectedDots : [UIView] = []
    var addressTextView = UITextView()
    let nextButtonLabel = UILabel()
    let nextButton = UIButton()
    
    var mapView = GMSMapView()
    var userLocationMarker = GMSMarker()
    let geocoder = GMSGeocoder()
    var currentLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    
    var currentPageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        
        let numberOfPages = self.titleLabelText.count
        let circleViewWidth = self.view.frame.width * 0.0408
        let circleViewSpacing = circleViewWidth
        let totalCircleViewWidth = (circleViewWidth * CGFloat(numberOfPages)) + (circleViewSpacing * CGFloat(numberOfPages - 1))
        for index in 0..<numberOfPages {
            
            
            
            // set up unselected circle views
            
            let currentCircleViewXPosition = ((self.view.frame.width - totalCircleViewWidth) / 2) + ((circleViewWidth + circleViewSpacing) * CGFloat(index))
            
            let newUnselectedView = UIView()
            newUnselectedView.frame = CGRect(x: currentCircleViewXPosition, y: self.view.frame.height * 0.93, width: circleViewWidth, height: circleViewWidth)
            newUnselectedView.backgroundColor = UIColor.clear
            newUnselectedView.layer.borderColor = UIColor.wrLightText().cgColor
            newUnselectedView.layer.borderWidth = self.view.frame.width * 0.004
            newUnselectedView.layer.cornerRadius = circleViewWidth / 2
            self.view.addSubview(newUnselectedView)
            self.scrollImagesUnselectedDots.append(newUnselectedView)
        }
        
        self.scrollImagesSelectedDot.frame = CGRect(x: self.scrollImagesUnselectedDots[0].frame.origin.x, y: self.view.frame.height * 0.93, width: circleViewWidth, height: circleViewWidth)
        self.scrollImagesSelectedDot.backgroundColor = UIColor.wrGreen()
        self.scrollImagesSelectedDot.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.scrollImagesSelectedDot.layer.shadowOpacity = 0.3
        self.scrollImagesSelectedDot.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.scrollImagesSelectedDot.layer.shadowRadius = self.view.frame.height * 0.009
        self.scrollImagesSelectedDot.layer.cornerRadius = circleViewWidth / 2
        self.view.addSubview(self.scrollImagesSelectedDot)
        
        self.nextButtonLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.nextButtonLabel.textColor = UIColor.wrGreen()
        self.nextButtonLabel.textAlignment = .right
        self.nextButtonLabel.text = "next"
        self.nextButtonLabel.frame = CGRect(x: self.sideMargin, y: self.scrollImagesSelectedDot.frame.origin.y - ((self.smallLabelHeight - self.scrollImagesSelectedDot.frame.height) / 2) , width: self.standardWidth, height: self.smallLabelHeight)
        self.view.addSubview(self.nextButtonLabel)
        
        
        
        let nextButtonWidth = self.view.frame.width / 4
        let nextButtonHeight  = self.view.frame.height / 10
        self.nextButton.frame = CGRect(x: self.view.frame.width - nextButtonWidth, y: self.view.frame.height - nextButtonHeight, width: nextButtonWidth, height: nextButtonHeight)
        self.nextButton.addTarget(self, action: #selector(GettingStartedViewController.nextPageButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(self.nextButton)
        
        
        self.setupNewPage(0)
        self.view.addSubview(self.pageViews[0])
    }
    
    func setupNewPage(_ withIndex : Int) {
        let newPageIndex = withIndex
        
        let newView = UIView()
        newView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.877)
        //self.view.addSubview(newView)
        self.pageViews.append(newView)
        
        let loadingBarView = UIView()
        loadingBarView.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.114, width: standardWidth / 5, height: self.view.frame.height * 0.0051)
        loadingBarView.backgroundColor = UIColor.wrGreen()
        newView.addSubview(loadingBarView)
        
        let titleLabel = UILabel()
        titleLabel.font = getFont(0, screenHeight: self.view.frame.height)
        titleLabel.textColor = UIColor.wrText()
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.135, width: self.standardWidth, height: self.standardLabelHeight)
        newView.addSubview(titleLabel)
        
        let imageYPosition = self.view.frame.height * 0.213
        let newImageView = UIImageView()
        newImageView.frame = CGRect(x: 0, y: imageYPosition, width: self.view.frame.width, height: self.view.frame.width)
        newView.addSubview(newImageView)
        
        
        let newTextViewYPosition = self.view.frame.height * (0.862 - self.descriptorTextFieldHeights[newPageIndex])
        let descriptorTextView = UITextView()
        descriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
        descriptorTextView.textColor = UIColor.wrText()
        descriptorTextView.textAlignment = .center
        descriptorTextView.frame = CGRect(x: self.sideMargin, y: newTextViewYPosition, width: self.standardWidth, height: self.view.frame.height * self.descriptorTextFieldHeights[newPageIndex])
        descriptorTextView.isEditable = false
        descriptorTextView.isSelectable = false
        descriptorTextView.isScrollEnabled = false
        descriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        newView.addSubview(descriptorTextView)
        
        
        if newPageIndex == self.titleLabelText.count - 1 {
            // on last page - address
            self.addressTextView = descriptorTextView
            titleLabel.text = "my address"
            self.nextButtonLabel.text = "done"
            
            // top text view
            let topTextView = UITextView()
            topTextView.font = getFont(2, screenHeight: self.view.frame.height)
            topTextView.textColor = UIColor.wrLightText()
            topTextView.textAlignment = .left
            topTextView.frame = CGRect(x: self.sideMargin, y: titleLabel.frame.origin.y + titleLabel.frame.height, width: self.standardWidth, height: self.view.frame.height / 10)
            topTextView.isEditable = false
            topTextView.isSelectable = false
            topTextView.isScrollEnabled = false
            topTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
            topTextView.text = "your address is required to calculate ride times and for payment processing."
            newView.addSubview(topTextView)
            
            
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
            let center = CurrentUser.pickupLocation
            let mapRect = CGRect(x: 0, y: self.view.frame.height * 0.281, width: self.view.frame.width, height: self.view.frame.height * 0.415)
            let camera = GMSCameraPosition(target: center, zoom: 14, bearing: 0, viewingAngle: 0)
            let map = GMSMapView.map(withFrame: mapRect, camera: camera)
            self.mapView = map
            
            self.mapView.delegate = self
            // Set the map style by passing the URL of the local file.
            do { if let styleURL = Bundle.main.url(forResource: "Style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {NSLog("Unable to find Style.json")}
            } catch {NSLog("One or more of the map styles failed to load. \(error)")}
            
            newView.addSubview(self.mapView)
            
            
            self.currentLocation = center
            
            let markerImage = UIImage(named: "location-marker")
            let markerImageView = UIImageView(image: markerImage)
            markerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
            
            self.userLocationMarker.position = center
            self.userLocationMarker.tracksViewChanges = true
            self.userLocationMarker.iconView = markerImageView
            self.userLocationMarker.isFlat = true
            self.userLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            self.userLocationMarker.map = self.mapView
            
            
            
            
        } else {
            titleLabel.text = self.titleLabelText[newPageIndex]
            
            if CurrentUser.signedUpAsDriver {
                newImageView.image = UIImage(named: self.imageNamesDriver[newPageIndex])
                descriptorTextView.text = self.descriptorTextDriver[newPageIndex]
            } else {
                newImageView.image = UIImage(named: self.imageNamesRider[newPageIndex])
                descriptorTextView.text = self.descriptorTextRider[newPageIndex]
            }
        }
    }
    
    func nextPageButtonPressed(_ sender: UIButton) {
        print("next button pressed")
        sender.isEnabled = false
        if self.currentPageIndex == self.titleLabelText.count - 1 {
            
            /*
 
             
             $stripeID = $_POST['stripeid'];
             $city = $_POST['city'];
             $country = $_POST['country'];
             $lineA = $_POST['linea'];
             $lineB = $_POST['lineb'];
             $postalCode = $_POST['postalcode'];
             $state = $_POST['state'];
 
            */
            
            // update stripe acct info
            let stripePostData : [String : Any] = ["stripeid":CurrentUser.stripeAccountID,"city":CurrentUser.city,"linea":CurrentUser.streetAddressA, "lineb":CurrentUser.streetAddressB,"postalcode":CurrentUser.postalCode,"state":CurrentUser.province,"country":CurrentUser.country]
            
            let stripeSendURL = "http://workride.ca/payment/update-account-address.php"
            let stripeParams = stripePostData
            
            let stripeAcctManager = AFHTTPSessionManager()
            stripeAcctManager.post(stripeSendURL, parameters: stripeParams, success: { (operation, responseObject) -> Void in
                if let response = responseObject as? [String : Any] {
                    print("\nresponse:\n\(response)")
                   
                    
                }
                
            }) { (operation, error) -> Void in
                print("failure operation:\n\(String(describing: operation))")
                print("\nerror:\n\(error)")
            }
            
            
            
            // update user info
            let userInfoRef = Database.database().reference().child("users").child("userinfo").child(CurrentUser.firebaseUID)
            userInfoRef.child("city").setValue(CurrentUser.city)
            userInfoRef.child("province").setValue(CurrentUser.province)
            userInfoRef.child("country").setValue(CurrentUser.country)
            userInfoRef.child("streetaddressa").setValue(CurrentUser.streetAddressA)
            userInfoRef.child("streetaddressb").setValue(CurrentUser.streetAddressB)
            userInfoRef.child("postalcode").setValue(CurrentUser.postalCode)
            
            // update pickup location
            let pickupInfoRef = Database.database().reference().child("users").child("pickupinfo")
            userInfoRef.child("lat").setValue(CurrentUser.pickupLocation.latitude)
            userInfoRef.child("lng").setValue(CurrentUser.pickupLocation.longitude)
            
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.setupNewPage(self.currentPageIndex + 1)
            self.pageViews[self.currentPageIndex + 1].frame.origin.x = self.view.frame.width
            self.view.addSubview(self.pageViews[self.currentPageIndex + 1])
            
            let circleViewSpacing = self.scrollImagesUnselectedDots[1].frame.origin.x - self.scrollImagesUnselectedDots[0].frame.origin.x
            
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.pageViews[self.currentPageIndex].frame.origin.x = -self.view.frame.width
                self.pageViews[self.currentPageIndex + 1].frame.origin.x = 0
                self.scrollImagesSelectedDot.frame.origin.x += circleViewSpacing
            }, completion: { (finished) in
                self.pageViews[self.currentPageIndex].removeFromSuperview()
                self.currentPageIndex += 1
                sender.isEnabled = true
            })
        }
        
    }
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.userLocationMarker.position = position.target
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {

        self.geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
            
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                print(response?.firstResult())
                
                CurrentUser.city = result.locality!
                CurrentUser.postalCode = result.postalCode!
                CurrentUser.province = result.administrativeArea!
                CurrentUser.country = result.country!
                CurrentUser.pickupLocation = self.currentLocation
                CurrentUser.streetAddressA = (result.lines?[0])!
                CurrentUser.streetAddressB = ""
                
                self.currentLocation = cameraPosition.target
                
                self.userLocationMarker.position = cameraPosition.target
                self.userLocationMarker.title = result.lines?[0]
                self.userLocationMarker.snippet = result.lines?[1]
                self.userLocationMarker.map = self.mapView
                
                self.addressTextView.text = "\((result.lines?[0])!)\n\((result.lines?[1])!)"
            }
        }
        
    }
    
}
