//
//  ProfileViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-05.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileiewController: UIViewController, UIScrollViewDelegate, GMSMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
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

    
    let myInfoLabel = UILabel()
    let paymentLabel = UILabel()
    let settingsLabel = UILabel()
    let myInfoButton = UIButton()
    let paymentButton = UIButton()
    let settingsButton = UIButton()
    var currentPageIndex = 0
    
    let contentViewsScrollView = UIScrollView()
    
    let myInfoContentView = UIView()
    let paymentContentView = UIView()
    let settingsContentView = UIView()
    
    
    // myInfoContentView subviews
    let imagePicker = UIImagePickerController()
    
    let MIProfileImageView = UIImageView()
    let MIEditProfileImageView = UIView()
    let MIEditProfileImageImageView = UIImageView()
    let MIEditProfileImageButton = UIButton()
    let MINameLabel = UILabel()
    let MIEmailLabel = UILabel()
    let MIBusinessNameLabel = UILabel()
    let MIBusinessSubLabel = UILabel()
    let MIPickupLocationLabel = UILabel()
    var mapView = GMSMapView()
    var userLocationMarker = GMSMarker()
    let MIEditPickupLocButton = UIButton()
    
    
    
    
    
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
        self.headerLabel.text = "profile"
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
        let cardYPosition = self.view.frame.height * 0.04
        self.contentViewsScrollView.frame = CGRect(x: 0, y: self.view.frame.height * 0.157, width: self.view.frame.width, height: self.view.frame.height * 0.843)
        self.contentViewsScrollView.isPagingEnabled = true
        self.contentViewsScrollView.showsHorizontalScrollIndicator = false
        self.contentViewsScrollView.showsVerticalScrollIndicator = false
        self.contentViewsScrollView.delegate = self
        self.view.addSubview(self.contentViewsScrollView)
        
        let navLabelWidth = (self.view.frame.width - (2 * self.smallSideMargin)) / 3
        let navLabelYPosition = self.contentViewsScrollView.frame.origin.y - self.smallLabelHeight + (cardYPosition / 2)
        self.myInfoLabel.font = getFont(3, screenHeight: self.view.frame.height)
        self.myInfoLabel.textColor = UIColor.wrWhite()
        self.myInfoLabel.textAlignment = NSTextAlignment.center
        self.myInfoLabel.text = "my info"
        self.myInfoLabel.frame = CGRect(x: self.smallSideMargin, y: navLabelYPosition, width: navLabelWidth, height: self.smallLabelHeight)
        self.view.addSubview(self.myInfoLabel)
        
        self.paymentLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.paymentLabel.textColor = UIColor.wrWhite()
        self.paymentLabel.textAlignment = NSTextAlignment.center
        self.paymentLabel.text = "payment"
        self.paymentLabel.frame = CGRect(x: self.smallSideMargin + navLabelWidth, y: navLabelYPosition, width: navLabelWidth, height: self.smallLabelHeight)
        self.view.addSubview(self.paymentLabel)
        
        self.settingsLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.settingsLabel.textColor = UIColor.wrWhite()
        self.settingsLabel.textAlignment = NSTextAlignment.center
        self.settingsLabel.text = "settings"
        self.settingsLabel.frame = CGRect(x: self.smallSideMargin + navLabelWidth + navLabelWidth, y: navLabelYPosition, width: navLabelWidth, height: self.smallLabelHeight)
        self.view.addSubview(self.settingsLabel)
        
        self.myInfoButton.frame = self.myInfoLabel.frame
        self.myInfoButton.addTarget(self, action: #selector(ProfileiewController.navButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(self.myInfoButton)
        
        self.paymentButton.frame = self.paymentLabel.frame
        self.paymentButton.addTarget(self, action: #selector(ProfileiewController.navButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(self.paymentButton)
        
        self.settingsButton.frame = self.settingsLabel.frame
        self.settingsButton.addTarget(self, action: #selector(ProfileiewController.navButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(self.settingsButton)
        
        
        // my info content subview
        self.myInfoContentView.frame = CGRect(x: self.smallSideMargin, y: cardYPosition, width: self.view.frame.width - (2 * self.smallSideMargin), height: self.contentViewsScrollView.frame.height - (2 * cardYPosition))
        self.myInfoContentView.layer.cornerRadius = self.view.frame.width * 0.036
        self.myInfoContentView.layer.shadowColor = UIColor.black.cgColor
        self.myInfoContentView.layer.shadowRadius = self.view.frame.width * 0.024
        self.myInfoContentView.layer.shadowOpacity = 0.2
        self.myInfoContentView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.myInfoContentView.backgroundColor = UIColor.wrWhite()
        self.contentViewsScrollView.addSubview(self.myInfoContentView)
        
        self.imagePicker.delegate = self
        
        let profileImageHeight = self.view.frame.height * 0.18
        let profileImageYPosition = self.view.frame.height * 0.064
        let profileImageXPosition = (self.myInfoContentView.frame.width - profileImageHeight) / 2.0
        
        self.MIProfileImageView.frame = CGRect(x: profileImageXPosition, y: profileImageYPosition, width: profileImageHeight, height: profileImageHeight)
        self.MIProfileImageView.image = CurrentUser.profileImage
        self.MIProfileImageView.contentMode = .scaleAspectFill
        self.MIProfileImageView.layer.cornerRadius = profileImageHeight / 2
        self.MIProfileImageView.clipsToBounds = true
        self.myInfoContentView.addSubview(self.MIProfileImageView)
                
        let editButtonHeight = profileImageHeight * 0.275
        self.MIEditProfileImageView.frame = CGRect(x: profileImageXPosition + profileImageHeight - editButtonHeight, y: profileImageYPosition + profileImageHeight - editButtonHeight, width: editButtonHeight, height: editButtonHeight)
        self.MIEditProfileImageView.backgroundColor = UIColor.wrGreen()
        self.MIEditProfileImageView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.MIEditProfileImageView.layer.shadowOpacity = 0.7
        self.MIEditProfileImageView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.MIEditProfileImageView.layer.shadowRadius = self.view.frame.height * 0.009
        self.MIEditProfileImageView.layer.cornerRadius = editButtonHeight / 2
        self.myInfoContentView.addSubview(self.MIEditProfileImageView)
        
        self.MIEditProfileImageImageView.frame = self.MIEditProfileImageView.frame
        self.MIEditProfileImageImageView.image = UIImage(named: "edit-photo-camera")
        self.myInfoContentView.addSubview(self.MIEditProfileImageImageView)
        
        self.MIEditProfileImageButton.frame = self.MIProfileImageView.frame
        self.MIEditProfileImageButton.addTarget(self, action: #selector(ProfileiewController.editProfileImageButtonPressed(_:)), for: .touchUpInside)
        self.myInfoContentView.addSubview(self.MIEditProfileImageButton)
        
        self.MINameLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.MINameLabel.textColor = UIColor.wrText()
        self.MINameLabel.textAlignment = NSTextAlignment.center
        self.MINameLabel.text = CurrentUser.fullName.lowercased()
        self.MINameLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.27, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.myInfoContentView.addSubview(self.MINameLabel)
        
        self.MIEmailLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.MIEmailLabel.textColor = UIColor.wrLightText()
        self.MIEmailLabel.textAlignment = NSTextAlignment.center
        self.MIEmailLabel.text = CurrentUser.email.lowercased()
        self.MIEmailLabel.frame = CGRect(x: self.smallSideMargin, y: self.MINameLabel.frame.origin.y + self.MINameLabel.frame.height, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.myInfoContentView.addSubview(self.MIEmailLabel)
        
        
        
        
        self.MIBusinessNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.MIBusinessNameLabel.textColor = UIColor.wrText()
        self.MIBusinessNameLabel.textAlignment = NSTextAlignment.center
        self.MIBusinessNameLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.418, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.MIBusinessNameLabel.text = CurrentUser.business.name.lowercased()
        self.myInfoContentView.addSubview(self.MIBusinessNameLabel)
        
        
        self.MIBusinessSubLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.MIBusinessSubLabel.textColor = UIColor.wrLightText()
        self.MIBusinessSubLabel.textAlignment = NSTextAlignment.center
        self.MIBusinessSubLabel.text = "business name"
        self.MIBusinessSubLabel.frame = CGRect(x: self.smallSideMargin, y: self.MIBusinessNameLabel.frame.origin.y + self.MIBusinessNameLabel.frame.height, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.myInfoContentView.addSubview(self.MIBusinessSubLabel)
        
        let mapContentView = UIView()
        mapContentView.frame.size = CGSize(width: self.myInfoContentView.frame.size.width, height: (self.view.frame.height * 0.16) + (self.view.frame.width * 0.036))
        mapContentView.frame.origin = CGPoint(x: 0, y: self.myInfoContentView.frame.height - mapContentView.frame.size.height)
        mapContentView.layer.cornerRadius = self.view.frame.width * 0.036
        mapContentView.clipsToBounds = true
        mapContentView.layer.masksToBounds = true
        self.myInfoContentView.addSubview(mapContentView)
        
        let center = CurrentUser.pickupLocation
        let mapRect = CGRect(x: 0, y: self.view.frame.height * 0.036, width: self.myInfoContentView.frame.width, height: self.view.frame.height * 0.21)
        let camera = GMSCameraPosition(target: center, zoom: 13, bearing: 0, viewingAngle: 0) //MKMapCamera(lookingAtCenter: center, fromDistance: altitudeArray[0], pitch: self.standardPitch, heading: 0)
        let map = GMSMapView.map(withFrame: mapRect, camera: camera)
        self.mapView = map
        
        
        self.mapView.delegate = self
        // Set the map style by passing the URL of the local file.
        do { if let styleURL = Bundle.main.url(forResource: "Style", withExtension: "json") {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } else {NSLog("Unable to find Style.json")}
        } catch {NSLog("One or more of the map styles failed to load. \(error)")}
        
        mapContentView.addSubview(self.mapView)
        
        self.MIEditPickupLocButton.frame = mapContentView.frame
        self.MIEditPickupLocButton.addTarget(self, action: #selector(ProfileiewController.editPickupLocButtonPressed(_:)), for: .touchUpInside)
        self.myInfoContentView.addSubview(self.MIEditPickupLocButton)
        
        
        let markerImage = UIImage(named: "location-marker")
        let markerImageView = UIImageView(image: markerImage)
        markerImageView.frame.size = CGSize(width: self.view.frame.width * 0.16, height: self.view.frame.width * 0.16)
        
        self.userLocationMarker.position = center
        self.userLocationMarker.tracksViewChanges = true
        self.userLocationMarker.iconView = markerImageView
        self.userLocationMarker.isFlat = true
        self.userLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.userLocationMarker.map = self.mapView
        
        
        self.MIPickupLocationLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.MIPickupLocationLabel.textColor = UIColor.wrLightText()
        self.MIPickupLocationLabel.textAlignment = NSTextAlignment.center
        self.MIPickupLocationLabel.text = "my pickup location"
        self.MIPickupLocationLabel.frame = CGRect(x: self.smallSideMargin, y: mapContentView.frame.origin.y - (self.smallLabelHeight / 2), width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.myInfoContentView.addSubview(self.MIPickupLocationLabel)
        
        // payment content subview
        self.paymentContentView.frame = CGRect(x: self.smallSideMargin + self.view.frame.width, y: cardYPosition, width: self.view.frame.width - (2 * self.smallSideMargin), height: self.contentViewsScrollView.frame.height - (2 * cardYPosition))
        self.paymentContentView.layer.cornerRadius = self.view.frame.width * 0.036
        self.paymentContentView.layer.shadowColor = UIColor.black.cgColor
        self.paymentContentView.layer.shadowRadius = self.view.frame.width * 0.024
        self.paymentContentView.layer.shadowOpacity = 0.2
        self.paymentContentView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.paymentContentView.backgroundColor = UIColor.wrWhite()
        self.contentViewsScrollView.addSubview(self.paymentContentView)
        
        if CurrentUser.signedUpAsDriver {
            
        } else {
            let paymentRideFareLabel = UILabel()
            paymentRideFareLabel.font = getFont(4, screenHeight: self.view.frame.height)
            paymentRideFareLabel.textColor = UIColor.wrText()
            paymentRideFareLabel.textAlignment = .center
            paymentRideFareLabel.text = GetMoneyString(0)
            paymentRideFareLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.064, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * self.goldenRatio)
            self.paymentContentView.addSubview(paymentRideFareLabel)
            
            let paymentRideFareDescriptorTextView = UITextView()
            paymentRideFareDescriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
            paymentRideFareDescriptorTextView.textColor = UIColor.wrLightText()
            paymentRideFareDescriptorTextView.textAlignment = NSTextAlignment.center
            paymentRideFareDescriptorTextView.text = "the fees for your rides are covered by your company"
            paymentRideFareDescriptorTextView.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.16, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * 3)
            paymentRideFareDescriptorTextView.isEditable = false
            paymentRideFareDescriptorTextView.textAlignment = .center
            paymentRideFareDescriptorTextView.isSelectable = false
            paymentRideFareDescriptorTextView.isScrollEnabled = false
            //paymentRideFareDescriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
            self.paymentContentView.addSubview(paymentRideFareDescriptorTextView)
            
            let noPaymentInfoRequiredLabel = UILabel()
            noPaymentInfoRequiredLabel.font = getFont(2, screenHeight: self.view.frame.height)
            noPaymentInfoRequiredLabel.textColor = UIColor.wrLightText()
            noPaymentInfoRequiredLabel.textAlignment = .center
            noPaymentInfoRequiredLabel.text = "no payment information required"
            noPaymentInfoRequiredLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.412, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
            self.paymentContentView.addSubview(noPaymentInfoRequiredLabel)
        }
        
        // settings content subview
        self.settingsContentView.frame = CGRect(x: self.smallSideMargin + self.view.frame.width + self.view.frame.width, y: cardYPosition, width: self.view.frame.width - (2 * self.smallSideMargin), height: self.contentViewsScrollView.frame.height - (2 * cardYPosition))
        self.settingsContentView.layer.cornerRadius = self.view.frame.width * 0.036
        self.settingsContentView.layer.shadowColor = UIColor.black.cgColor
        self.settingsContentView.layer.shadowRadius = self.view.frame.width * 0.024
        self.settingsContentView.layer.shadowOpacity = 0.2
        self.settingsContentView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.settingsContentView.backgroundColor = UIColor.wrWhite()
        self.contentViewsScrollView.addSubview(self.settingsContentView)
        
        
        let settingsComingSoonLabel = UILabel()
        settingsComingSoonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        settingsComingSoonLabel.textColor = UIColor.wrLightText()
        settingsComingSoonLabel.textAlignment = .center
        settingsComingSoonLabel.text = "coming soon"
        settingsComingSoonLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.33, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.settingsContentView.addSubview(settingsComingSoonLabel)
        
        let settingsDescriptorTextView = UITextView()
        settingsDescriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
        settingsDescriptorTextView.textColor = UIColor.wrLightText()
        settingsDescriptorTextView.textAlignment = NSTextAlignment.center
        settingsDescriptorTextView.text = "settings for your workride account will be released in coming updates"
        settingsDescriptorTextView.frame = CGRect(x: self.smallSideMargin, y: settingsComingSoonLabel.frame.origin.y + settingsComingSoonLabel.frame.height, width: self.myInfoContentView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight * 3)
        settingsDescriptorTextView.isEditable = false
        settingsDescriptorTextView.textAlignment = .center
        settingsDescriptorTextView.isSelectable = false
        settingsDescriptorTextView.isScrollEnabled = false
        //settingsDescriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        self.settingsContentView.addSubview(settingsDescriptorTextView)
        
        self.contentViewsScrollView.contentSize.width = self.view.frame.width * 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let camera = GMSCameraPosition(target: CurrentUser.pickupLocation, zoom: 13, bearing: 0, viewingAngle: 0)
        self.mapView.camera = camera
        self.userLocationMarker.position = CurrentUser.pickupLocation
    }
    
    func navButtonPressed(_ sender: UIButton) {
        switch sender {
        case self.myInfoButton:
            print("my info button")
            self.contentViewsScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        case self.paymentButton:
            print("payment button")
            self.contentViewsScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        case self.settingsButton:
            print("settings button")
            self.contentViewsScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        default:
            print("nawh bruh")
            break
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("view did scroll")
        //print(scrollView.contentOffset)
        let pageIndex = Int(scrollView.contentOffset.x / self.view.frame.width)
        self.currentPageIndex = pageIndex
        
        switch pageIndex {
        case 0:
            self.myInfoLabel.font = getFont(3, screenHeight: self.view.frame.height)
            self.paymentLabel.font = getFont(2, screenHeight: self.view.frame.height)
            self.settingsLabel.font = getFont(2, screenHeight: self.view.frame.height)
        case 1:
            self.myInfoLabel.font = getFont(2, screenHeight: self.view.frame.height)
            self.paymentLabel.font = getFont(3, screenHeight: self.view.frame.height)
            self.settingsLabel.font = getFont(2, screenHeight: self.view.frame.height)
        case 2:
            self.myInfoLabel.font = getFont(2, screenHeight: self.view.frame.height)
            self.paymentLabel.font = getFont(2, screenHeight: self.view.frame.height)
            self.settingsLabel.font = getFont(3, screenHeight: self.view.frame.height)
        default:
            break
        }
    }
    
    func editPickupLocButtonPressed(_ sender: UIButton) {
        print("editPickupLocButtonPressed")
        
        let editPULVC = self.storyboard!.instantiateViewController(withIdentifier: "PickupLocationViewController") as! PickupLocationViewController
        editPULVC.transitioningDelegate = self
        self.present(editPULVC, animated: true, completion: nil)
        
    }
    
    func editProfileImageButtonPressed(_ sender: UIButton) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("a")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("pickedImage = \(pickedImage)")
            self.MIProfileImageView.contentMode = .scaleAspectFill
            self.MIProfileImageView.image = pickedImage
            CurrentUser.profileImage = pickedImage
            
            let imageData: Data = UIImageJPEGRepresentation(pickedImage, 1.0)!
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let filePathRef = storageRef.child("userImages/driver/\(CurrentUser.firebaseUID)/profileImage/image.jpg")
            
            
            filePathRef.putData(imageData, metadata: nil) { metadata, error in
                if (error != nil) {
                    
                } else {
                    
                    let downloadURL = metadata!.downloadURL
                    print(downloadURL()?.absoluteString)
                    self.setUserProfileImageURL(downloadURL()!)
                }
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUserProfileImageURL(_ profileImageURL: URL) {
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            
            changeRequest.photoURL = profileImageURL
            
            changeRequest.commitChanges { error in
                if error != nil {
                    print("not goot")
                } else {
                    print("all goot")
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
