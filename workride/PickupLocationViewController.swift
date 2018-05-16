//
//  PickupLocationViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-09.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase
import GoogleMaps

class PickupLocationViewController: UIViewController, GMSMapViewDelegate, UIViewControllerTransitioningDelegate {
    
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
    var currentPickupLocation = CLLocationCoordinate2D()
    
    let topGradImageView = UIImageView()
    let bottomGradImageView = UIImageView()
    
    let titleLabel = UILabel()
    let titleSubLabel = UILabel()
    
    let closeButtonView = UIView()
    let closeButtonButton = UIButton()
    let closeButtonImageView = UIImageView()
    
    let bottomInfoView = UIView()
    
    let addressInfoLabel = UILabel()
    let addressStreetLabel = UILabel()
    let addressCityLabel = UILabel()
    
    let fareLabel = UILabel()
    let fareSubTextView = UITextView()
    var fareSpinnerView = UIActivityIndicatorView()
    
    let editLocButtonView = UIView()
    let editLocButtonImageView = UIImageView()
    let editLocButtonButton = UIButton()
    var editLocSpinnerView = UIActivityIndicatorView()
    
    var isEditingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.wrOffWhite()
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.smallSideMargin = self.view.frame.width * 0.08
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        
        
        // set up map
        let center = CurrentUser.pickupLocation
        let mapRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let camera = GMSCameraPosition(target: center, zoom: 14, bearing: 0, viewingAngle: 0)
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
        
        let markerImage = UIImage(named: "location-marker")
        let markerImageView = UIImageView(image: markerImage)
        markerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
        
        self.userLocationMarker.position = center
        self.userLocationMarker.tracksViewChanges = true
        self.userLocationMarker.iconView = markerImageView
        self.userLocationMarker.isFlat = true
        self.userLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.userLocationMarker.map = self.mapView
        
        // setup top grad
        self.topGradImageView.image = UIImage(named: "top-grad")
        self.topGradImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.22)
        self.view.addSubview(self.topGradImageView)
        
        // top grad label
        self.titleLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.titleLabel.textColor = UIColor.wrText()
        self.titleLabel.textAlignment = NSTextAlignment.left
        
        if CurrentUser.signedUpAsDriver {
            self.titleLabel.text = "leave location"
        } else {
            self.titleLabel.text = "pickup location"
        }
        self.titleLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.072, width: standardWidth, height: standardLabelHeight)
        self.view.addSubview(self.titleLabel)
        
        self.titleSubLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.titleSubLabel.textColor = UIColor.wrLightText()
        self.titleSubLabel.textAlignment = NSTextAlignment.left
        self.titleSubLabel.text = "pan to select a new pickup location"
        self.titleSubLabel.frame = CGRect(x: self.smallSideMargin - self.view.frame.width, y: self.titleLabel.frame.origin.y + self.titleLabel.frame.height, width: standardWidth, height: self.smallLabelHeight)
        self.view.addSubview(self.titleSubLabel)
        
        // close button
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
        
        // set up bottom grad
    
        let bottomGradHeight = self.view.frame.height * 0.555
        self.bottomInfoView.frame = CGRect(x: 0, y: self.view.frame.height - bottomGradHeight, width: self.view.frame.width, height: bottomGradHeight)
        self.view.addSubview(self.bottomInfoView)
        
        self.bottomGradImageView.image = UIImage(named: "bottom-grad")
        self.bottomGradImageView.frame.origin = CGPoint.zero
        self.bottomGradImageView.frame.size = self.bottomInfoView.frame.size
        self.bottomInfoView.addSubview(self.bottomGradImageView)
        
        // pickup labels
        self.addressInfoLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.addressInfoLabel.textColor = UIColor.wrLightText()
        self.addressInfoLabel.textAlignment = NSTextAlignment.left
        
        if CurrentUser.signedUpAsDriver {
            self.addressInfoLabel.text = "leave address"
        } else {
            self.addressInfoLabel.text = "pickup address"
        }
        self.addressInfoLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.142, width: self.standardWidth, height: self.smallLabelHeight)
        self.bottomInfoView.addSubview(self.addressInfoLabel)
        
        self.addressStreetLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.addressStreetLabel.textColor = UIColor.wrText()
        self.addressStreetLabel.textAlignment = NSTextAlignment.left
        self.addressStreetLabel.text = ""
        self.addressStreetLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.19, width: self.standardWidth, height: self.standardLabelHeight)
        self.bottomInfoView.addSubview(self.addressStreetLabel)
        
        self.addressCityLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.addressCityLabel.textColor = UIColor.wrText()
        self.addressCityLabel.textAlignment = NSTextAlignment.left
        self.addressCityLabel.text = ""
        self.addressCityLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.25, width: self.standardWidth, height: self.standardLabelHeight)
        self.bottomInfoView.addSubview(self.addressCityLabel)
        
        self.fareLabel.font = getFont(4, screenHeight: self.view.frame.height)
        self.fareLabel.textColor = UIColor.wrText()
        self.fareLabel.textAlignment = NSTextAlignment.center
        self.fareLabel.text = GetMoneyString(CurrentUser.fare)
        self.fareLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.341, width: self.standardWidth, height: self.standardLabelHeight * self.goldenRatio)
        self.bottomInfoView.addSubview(self.fareLabel)
        
        
        self.fareSubTextView.font = getFont(2, screenHeight: self.view.frame.height)
        self.fareSubTextView.textColor = UIColor.wrLightText()
        self.fareSubTextView.textAlignment = NSTextAlignment.center
        
        if CurrentUser.signedUpAsDriver {
            self.fareSubTextView.text = "max ride payment\nbased on number of seats"
        } else {
            self.fareSubTextView.text = "ride fare\nbased on pickup location"
        }
        self.fareSubTextView.isEditable = false
        self.fareSubTextView.isSelectable = false
        self.fareSubTextView.isScrollEnabled = false
        self.fareSubTextView.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.425, width: self.standardWidth, height: self.smallLabelHeight * 2.5)
        self.bottomInfoView.addSubview(self.fareSubTextView)
        
        let editButtonHeight = self.view.frame.width * 0.184
        self.editLocButtonView.frame = CGRect(x: self.view.frame.width - self.sideMargin - editButtonHeight, y: self.addressInfoLabel.frame.origin.y - editButtonHeight, width: editButtonHeight, height: editButtonHeight)
        self.editLocButtonView.backgroundColor = UIColor.wrGreen()
        self.editLocButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.editLocButtonView.layer.shadowOpacity = 0.7
        self.editLocButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.editLocButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.editLocButtonView.layer.cornerRadius = editButtonHeight / 2
        self.bottomInfoView.addSubview(self.editLocButtonView)
        
        self.editLocButtonImageView.image = UIImage(named: "location-icon-white")
        self.editLocButtonImageView.frame.origin = CGPoint.zero
        self.editLocButtonImageView.frame.size = self.editLocButtonView.frame.size
        self.editLocButtonView.addSubview(self.editLocButtonImageView)
        
        self.editLocButtonButton.frame.size = self.editLocButtonView.frame.size
        self.editLocButtonButton.frame.origin = CGPoint.zero
        self.editLocButtonButton.addTarget(self, action: #selector(PickupLocationViewController.editLocButtonPressed(_:)), for: .touchUpInside)
        self.editLocButtonView.addSubview(self.editLocButtonButton)
        
        let suSpinnerViewHeight = self.view.frame.height * 0.112
        self.editLocSpinnerView.frame = CGRect(x: (self.editLocButtonView.frame.width - suSpinnerViewHeight) / 2, y: (self.editLocButtonView.frame.height - suSpinnerViewHeight) / 2, width: suSpinnerViewHeight, height: suSpinnerViewHeight)
        self.editLocSpinnerView.color = UIColor.wrWhite()
        self.editLocSpinnerView.hidesWhenStopped = true
        self.editLocButtonView.addSubview(self.editLocSpinnerView)
        
        self.fareSpinnerView.frame = CGRect(x: self.fareLabel.frame.origin.x + (self.fareLabel.frame.width - suSpinnerViewHeight) / 2, y: self.fareLabel.frame.origin.y + (self.fareLabel.frame.height - suSpinnerViewHeight) / 2, width: suSpinnerViewHeight, height: suSpinnerViewHeight)
        self.fareSpinnerView.color = UIColor.wrText()
        self.fareSpinnerView.hidesWhenStopped = true
        self.bottomInfoView.addSubview(self.fareSpinnerView)
        
    }
    
    func closeButtonPressed(_ sender: UIButton) {
        print("closeButtonPressed")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func editLocButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        print("editLocButtonPressed")
        let yTransition = self.bottomInfoView.frame.height - self.fareLabel.frame.origin.y
        
        if self.isEditingLocation {
            
            // upload change to db
            CurrentUser.pickupLocation = self.currentPickupLocation
            let locationInfoRef = Database.database().reference().child("users").child("pickupinfo").child(CurrentUser.firebaseUID)
            locationInfoRef.child("lat").setValue(self.currentPickupLocation.latitude as Double)
            locationInfoRef.child("lng").setValue(self.currentPickupLocation.longitude as Double)
            
            
            if CurrentUser.signedUpAsDriver == false {
                self.fareSpinnerView.startAnimating()
                self.fareLabel.isHidden = true
                // req format = {"businessuid":"<biz_UID>","bizlocationid":"<bizloc_ID>","lat":0.0,"lng":0.0}
                let mailchimpPOSTData : [String : Any] = ["businessuid":CurrentUser.business.uid,"bizlocationid":CurrentUser.business.locationid,"lat":CurrentUser.pickupLocation.latitude,"lng":CurrentUser.pickupLocation.longitude];
                
                
                let sendURL = "https://us-central1-workride-dc700.cloudfunctions.net/calculateFare"
                let params = mailchimpPOSTData
                
                let manager = AFHTTPSessionManager()
                manager.post(sendURL, parameters: params, success: { (operation, responseObject) -> Void in
                    if let response = responseObject as? [String : Any] {
                        print("\nresponse:\n\(response)")
                        let responseData = response["maxPayment"] as! Float
                        let fare = Int(responseData)
                        
                        
                        self.fareLabel.text = GetMoneyString(fare)
                        
                        self.fareSpinnerView.stopAnimating()
                        self.fareLabel.isHidden = false
                        
                        CurrentUser.fare = fare
                        locationInfoRef.child("fare").setValue(fare)
                    }
                    
                }) { (operation, error) -> Void in
                    print("failure operation:\n\(operation)")
                    print("\nerror:\n\(error)")
                }
            }
            
            // change UI
            self.editLocButtonImageView.image = UIImage(named: "location-icon-white")
            self.addressInfoLabel.text = "pickup address"
            self.titleLabel.text = "pickup location"
            
            UIView.animate(withDuration: 0.369, delay: 0, options: .curveEaseInOut, animations: {
                self.bottomInfoView.frame.origin.y -= yTransition
                self.closeButtonView.frame.origin.x -= self.view.frame.width
                self.titleSubLabel.frame.origin.x -= self.view.frame.width
            }, completion: { (finished) in
                sender.isEnabled = true
                
                self.isEditingLocation = false
                
            })
        } else {
            self.editLocButtonImageView.image = UIImage(named: "checkmark-white")
            self.addressInfoLabel.text = "selected address"
            self.titleLabel.text = "edit location"
            UIView.animate(withDuration: 0.369, delay: 0, options: .curveEaseInOut, animations: {
                self.bottomInfoView.frame.origin.y += yTransition
                self.closeButtonView.frame.origin.x += self.view.frame.width
                self.titleSubLabel.frame.origin.x += self.view.frame.width
            }, completion: { (finished) in
                sender.isEnabled = true
                
                self.isEditingLocation = true
                
            })
        }
        
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
        if self.isEditingLocation {
            self.editLocButtonImageView.isHidden = true
            self.editLocSpinnerView.startAnimating()
            self.editLocButtonButton.isEnabled = false
            self.geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
                self.editLocButtonImageView.isHidden = false
                self.editLocSpinnerView.stopAnimating()
                self.editLocButtonButton.isEnabled = true
                guard error == nil else {
                    return
                }
                
                if let result = response?.firstResult() {
                    
                    self.currentPickupLocation = cameraPosition.target
                    
                    self.userLocationMarker.position = cameraPosition.target
                    self.userLocationMarker.title = result.lines?[0]
                    self.userLocationMarker.snippet = result.lines?[1]
                    self.userLocationMarker.map = self.mapView
                    
                    self.addressStreetLabel.text = result.lines?[0]
                    self.addressCityLabel.text = result.lines?[1]
                }
            }
        }
    }
}
