//
//  SignUpViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-29.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //important constant definitions
    let goldenRatio : CGFloat = 1.61803398875
    let textExtraSpaceFactor : CGFloat = 1.25
    var standardLabelHeight: CGFloat = 0.0
    var smallLabelHeight: CGFloat = 0.0
    var sideMargin: CGFloat = 0.0
    var standardWidth: CGFloat = 0.0
    
    var signUpLabel = UILabel()
    var loadingBarView = UIView()
    
    var closeButtonView = UIView()
    var closeButtonImageView = UIImageView()
    var closeButton = UIButton()
    
    var nextButtonView = UIView()
    var nextButtonImageView = UIImageView()
    var nextButton = UIButton()
    
    var backButtonView = UIView()
    var backButtonLabel = UILabel()
    var backButton = UIButton()
    
    var businessSearchTableView = UITableView()
    let cellReuseIdentifier = "cell"
    var filtered: [String] = []
    var filteredBusiness: [Business] = []
    var keyboardReleaseGestureRecognizer = UITapGestureRecognizer()
    var keyboardReleaseEnabled = true
    
    var emailCheckSpinnerView = UIActivityIndicatorView()
    
    var passwordRequirementVerified: [Bool] = []
    var passwordRequirementLabels: [UILabel] = []
    let passwordRequirementMessages: [String] = ["At least 6 characters long", "Contains a capital letter", "Minimum of 1 number"]
    var passwordRequirementImageViews: [UIImageView] = []
    
    var rideButtonLabel = UILabel()
    var rideButtonView = UIView()
    var rideButton = UIButton()
    var driveButtonLabel = UILabel()
    var driveButtonView = UIView()
    var driveButton = UIButton()
    var selectedButtonView = UIView()
    var isDriver = false
    
    var signUpMasterView = UIView()
    
    var currentViewIndex: Int = 0
    var maxViewIndex: Int = 0
    var reEnteringPassword = false

    var signUpViews: [UIView] = []
    var textFields: [UITextField] = []
    var alertMarks: [UIImageView] = []
    var alertLabels: [UILabel] = []
    var underlineViews: [UIView] = []
    var validatedMarks: [UIImageView] = []
    
    var pageDescriptorString: [String] = ["my full name is", "i was born on", "i work at", "the email address i would like to use is", "i would like my   password to be", "last step! i would like to"]
    var pageDescriptorLinesOfText: [Int] = [1, 1, 1, 2, 2, 1]
    
    var viewValidated: [Bool] = [false, false, false, false, false, true]
    
    var emailErrorDescriptors: [String : String] = ["The email address is already in use by another account." : "this email is already in use", "The email address is badly formatted." : "please enter a valid email"]
    
    var businessData : [String] = []
    
    var searchableBizData : [Business] = []
    var selectedBusiness = Business()
    
    var settingUpView = UIView()
    var suHeaderLabel = UILabel()
    var suSpinnerView = UIActivityIndicatorView()
    
    var welcomeView = UIView()
    var wvWelcomeLabel = UILabel()
    var wvNameLabel = UILabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.keyboardReleaseGestureRecognizer = self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // grab biz data from db
        let bizDataRef = Database.database().reference().child("business").child("searchable").child("names")
        bizDataRef.observeSingleEvent(of: .value, with: {  (snapshot) in
            let bizData = snapshot.value as? NSArray
            for index in 0..<(bizData?.count)! {
                let currentBizData = (bizData?[index] as? NSDictionary)!
                let newBusiness = Business()
                newBusiness.name = currentBizData["name"] as! String
                newBusiness.uid = currentBizData["uid"] as! String
                
                let bizLocationData = currentBizData["locations"] as! NSArray
                for j in 0..<bizLocationData.count {
                    let newLocation = BusinessLocation()
                    let newLocationData = bizLocationData[j] as! NSDictionary
                    newLocation.descriptor = newLocationData["descriptor"] as! String
                    newLocation.locationid = newLocationData["locationid"] as! String
                    newBusiness.allLocations.append(newLocation)
                }
                self.searchableBizData.append(newBusiness)
                self.businessData.append(newBusiness.name)
            }
        })
        
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        
        let roundButtonHeight = self.view.frame.height / 8
        
        self.signUpMasterView.frame = self.view.frame
        self.view.addSubview(self.signUpMasterView)
        
        self.loadingBarView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.1964, width: standardWidth / 5, height: self.view.frame.height * 0.0051)
        self.loadingBarView.backgroundColor = UIColor.wrGreen()
        self.signUpMasterView.addSubview(self.loadingBarView)
        
        self.signUpLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.signUpLabel.textColor = UIColor.wrText()
        self.signUpLabel.textAlignment = NSTextAlignment.left
        self.signUpLabel.text = "sign up"
        self.signUpLabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.217, width: standardWidth, height: standardLabelHeight)
        self.signUpMasterView.addSubview(self.signUpLabel)
        
        
        let closeButtonHeight = self.view.frame.height * 0.045
        self.closeButtonView.frame = CGRect(x: self.view.frame.width - sideMargin - closeButtonHeight, y: self.view.frame.height * 0.0915, width: closeButtonHeight, height: closeButtonHeight)
        self.signUpMasterView.addSubview(self.closeButtonView)
        
        self.closeButtonImageView.frame.origin = CGPoint.zero
        self.closeButtonImageView.frame.size = self.closeButtonView.frame.size
        self.closeButtonImageView.image = UIImage(named: "close")
        self.closeButtonView.addSubview(self.closeButtonImageView)
        
        self.closeButton.frame.origin = CGPoint.zero
        self.closeButton.frame.size = self.closeButtonView.frame.size
        self.closeButton.addTarget(self, action: #selector(SignUpViewController.closeButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.closeButtonView.addSubview(self.closeButton)
        
        self.nextButtonView.backgroundColor = UIColor.clear
        self.nextButtonView.layer.cornerRadius = roundButtonHeight / 2
        self.nextButtonView.frame = CGRect(x: self.view.frame.width - sideMargin - roundButtonHeight, y: self.view.frame.height * 0.817, width: roundButtonHeight, height: roundButtonHeight)
        self.nextButtonView.layer.borderColor = UIColor.wrLightText().cgColor
        self.nextButtonView.layer.borderWidth = self.view.frame.width * 0.004
        self.signUpMasterView.addSubview(self.nextButtonView)
        
        self.nextButtonImageView.frame.origin = CGPoint.zero
        self.nextButtonImageView.frame.size = self.nextButtonView.frame.size
        self.nextButtonImageView.image = UIImage(named: "arrow-gray")
        self.nextButtonView.addSubview(self.nextButtonImageView)
        
        self.nextButton.frame.origin = CGPoint.zero
        self.nextButton.frame.size = self.nextButtonView.frame.size
        self.nextButton.addTarget(self, action: #selector(SignUpViewController.nextButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.nextButtonView.addSubview(self.nextButton)
        
        self.backButtonView.frame = CGRect(x: self.sideMargin, y: self.nextButtonView.frame.origin.y + ((self.nextButtonView.frame.height - self.standardLabelHeight) / 2), width: (self.view.frame.width / 2) - self.sideMargin, height: standardLabelHeight)
        self.backButtonView.frame.origin.x = -self.backButtonView.frame.width
        self.signUpMasterView.addSubview(self.backButtonView)
        
        self.backButtonLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.backButtonLabel.textColor = UIColor.wrLightText()
        self.backButtonLabel.textAlignment = NSTextAlignment.left
        self.backButtonLabel.text = "back"
        self.backButtonLabel.frame.origin = CGPoint.zero
        self.backButtonLabel.frame.size = self.backButtonView.frame.size
        self.backButtonView.addSubview(self.backButtonLabel)
        
        self.backButton.frame.origin = CGPoint.zero
        self.backButton.frame.size = self.backButtonView.frame.size
        self.backButton.addTarget(self, action: #selector(SignUpViewController.backButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.backButtonView.addSubview(self.backButton)
        
        // sign up views
        self.setUpNewSignUpView(0)
        
        self.signUpMasterView.isHidden = true
        self.backButton.isHidden = true
        self.signUpMasterView.frame.origin.x = self.view.frame.width
        
        
        // setting up account view
        self.settingUpView.frame = self.view.frame
        
        self.suHeaderLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.suHeaderLabel.textColor = UIColor.wrText()
        self.suHeaderLabel.textAlignment = NSTextAlignment.center
        self.suHeaderLabel.text = "setting up your account..."
        self.suHeaderLabel.frame = CGRect(x: 0, y: self.view.frame.height * 0.576, width: self.view.frame.width, height: self.standardLabelHeight)
        self.settingUpView.addSubview(self.suHeaderLabel)
        
        let suSpinnerViewHeight = self.view.frame.height * 0.112
        self.suSpinnerView.frame = CGRect(x: (self.view.frame.width - suSpinnerViewHeight) / 2, y: self.view.frame.height * 0.375, width: suSpinnerViewHeight, height: suSpinnerViewHeight)
        self.suSpinnerView.color = UIColor.wrGreen()
        self.settingUpView.addSubview(self.suSpinnerView)
        
        
        self.welcomeView.frame = self.view.frame
        
        self.wvWelcomeLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.wvWelcomeLabel.textColor = UIColor.wrText()
        self.wvWelcomeLabel.textAlignment = NSTextAlignment.center
        self.wvWelcomeLabel.text = "welcome to WorkRide,"
        self.wvWelcomeLabel.frame = CGRect(x: 0, y: (self.view.frame.height / 2) - standardLabelHeight, width: self.view.frame.width, height: standardLabelHeight)
        self.welcomeView.addSubview(self.wvWelcomeLabel)
        
        self.wvNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.wvNameLabel.textColor = UIColor.wrText()
        self.wvNameLabel.textAlignment = NSTextAlignment.center
        self.wvNameLabel.text = "friend"
        self.wvNameLabel.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: standardLabelHeight)
        self.welcomeView.addSubview(self.wvNameLabel)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.signUpMasterView.isHidden = false
        self.signUpMasterView.frame.origin.x = -self.view.frame.width
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseOut, animations: {
            self.signUpMasterView.frame.origin.x = 0
        }, completion: { (finished) in
            self.backButton.isHidden = false
        })
    }
    
    func setUpNewSignUpView(_ pageIndex: Int) {
        
        let newSignUpView = UIView()
        newSignUpView.frame.origin = CGPoint(x: 0, y: self.view.frame.height * 0.275)
        newSignUpView.frame.size = CGSize(width: self.view.frame.width, height: self.nextButtonView.frame.origin.y - newSignUpView.frame.origin.y)
        self.signUpViews.append(newSignUpView)
        
        let descriptorTextViewHeight = self.standardLabelHeight * CGFloat(self.pageDescriptorLinesOfText[pageIndex]) * 1.4
        let descriptorTextView = UITextView()
        descriptorTextView.font = getFont(0, screenHeight: self.view.frame.height)
        descriptorTextView.textColor = UIColor.wrText()
        descriptorTextView.textAlignment = NSTextAlignment.left
        descriptorTextView.text = self.pageDescriptorString[pageIndex]
        descriptorTextView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.142, width: standardWidth * 1.1, height: descriptorTextViewHeight)
        descriptorTextView.isEditable = false
        descriptorTextView.isSelectable = false
        descriptorTextView.isScrollEnabled = false
        descriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        newSignUpView.addSubview(descriptorTextView)
        
        if pageIndex < 5 {
            let newTF = UITextField()
            newTF.text = ""
            newTF.delegate = self
            newTF.font = getFont(0, screenHeight: self.view.frame.height)
            newTF.textColor = UIColor.wrText()
            newTF.autocapitalizationType = .none
            newTF.autocorrectionType = .no
            newTF.keyboardType = .default
            newTF.adjustsFontSizeToFitWidth = true
            newTF.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
            newTF.frame = CGRect(x: sideMargin, y: descriptorTextView.frame.origin.y + descriptorTextView.frame.height, width: standardWidth * 0.9, height: standardLabelHeight)
            newSignUpView.addSubview(newTF)
            self.textFields.append(newTF)
            
            let newTFUnderlineView = UIView()
            newTFUnderlineView.frame = CGRect(x: newTF.frame.origin.x, y: newTF.frame.origin.y + newTF.frame.height, width: newTF.frame.width, height: self.view.frame.height * 0.00225)
            newTFUnderlineView.backgroundColor = UIColor.wrText()
            newSignUpView.addSubview(newTFUnderlineView)
            self.underlineViews.append(newTFUnderlineView)
            
            let alertMarkImageView = UIImageView()
            let alertMarkImageViewHeight = self.view.frame.height * 0.03
            alertMarkImageView.frame = CGRect(x: newTF.frame.origin.x + newTF.frame.width, y: newTF.frame.origin.y + ((newTF.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
            alertMarkImageView.image = UIImage(named: "alert-mark")
            alertMarkImageView.isHidden = true
            newSignUpView.addSubview(alertMarkImageView)
            self.alertMarks.append(alertMarkImageView)
            
            let alertLabel = UILabel()
            alertLabel.font = getFont(2, screenHeight: self.view.frame.height)
            alertLabel.textColor = UIColor.wrAlert()
            alertLabel.textAlignment = NSTextAlignment.left
            alertLabel.text = "please enter your full name"
            alertLabel.frame = CGRect(x: sideMargin, y: newTFUnderlineView.frame.origin.y, width: newTFUnderlineView.frame.width, height: standardLabelHeight)
            alertLabel.isHidden = true
            newSignUpView.addSubview(alertLabel)
            self.alertLabels.append(alertLabel)
            
            
            let checkmarkImageView = UIImageView()
            checkmarkImageView.frame = CGRect(x: newTF.frame.origin.x + newTF.frame.width, y: newTF.frame.origin.y + ((newTF.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
            checkmarkImageView.image = UIImage(named: "checkmark-small")
            checkmarkImageView.isHidden = true
            newSignUpView.addSubview(checkmarkImageView)
            self.validatedMarks.append(checkmarkImageView)
            
            switch pageIndex {
            case 0:
                newTF.autocapitalizationType = .words
            case 1:
                newTF.keyboardType = .numberPad
                newTF.attributedPlaceholder = NSAttributedString(string: "dd/mm/yyyy", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
            case 2:
                self.businessSearchTableView.register(businessSearchCell.self, forCellReuseIdentifier: cellReuseIdentifier)
                self.businessSearchTableView.frame = CGRect(x: self.sideMargin, y: newTFUnderlineView.frame.origin.y + (newTFUnderlineView.frame.height * 3), width: self.standardWidth, height: self.view.frame.height * 0.27)
                self.businessSearchTableView.dataSource = self
                self.businessSearchTableView.delegate = self
                self.businessSearchTableView.separatorStyle = .none
                
                newSignUpView.addSubview(self.businessSearchTableView)
            case 3:
                newTF.keyboardType = .emailAddress
                
                self.emailCheckSpinnerView.frame = checkmarkImageView.frame
                self.emailCheckSpinnerView.color = UIColor.wrGreen()
                newSignUpView.addSubview(self.emailCheckSpinnerView)
                self.emailCheckSpinnerView.isHidden = true
            case 4:
                newTF.isSecureTextEntry = true
                let labelXPosition = self.view.frame.width * 0.195
                for jIndex in 0...self.passwordRequirementMessages.count - 1 {
                    let newLabelYPosition = self.textFields[self.currentViewIndex].frame.origin.y + ((self.textFields[self.currentViewIndex].frame.height + (CGFloat(jIndex) * self.smallLabelHeight)) * 1.2)
                    
                    // create labels
                    let newLabel = UILabel()
                    self.passwordRequirementLabels.append(newLabel)
                    newLabel.font = getFont(2, screenHeight: self.view.frame.height)
                    newLabel.textColor = UIColor.wrAlert()
                    newLabel.textAlignment = NSTextAlignment.left
                    newLabel.text = self.passwordRequirementMessages[jIndex]
                    newLabel.frame = CGRect(x: labelXPosition, y: newLabelYPosition, width: self.standardWidth, height: smallLabelHeight)
                    newSignUpView.addSubview(newLabel)
                    newLabel.isHidden = true
                    
                    // create images
                    let passwordVerificationImage = UIImageView()
                    self.passwordRequirementImageViews.append(passwordVerificationImage)
                    passwordVerificationImage.image = UIImage(named: "alert-circle-small")
                    passwordVerificationImage.frame.size = CGSize(width: self.view.frame.width * 0.0348, height: self.view.frame.width * 0.0348)
                    passwordVerificationImage.frame.origin = CGPoint(x: sideMargin, y: newLabelYPosition + ((smallLabelHeight - passwordVerificationImage.frame.height) / 2))
                    newSignUpView.addSubview(passwordVerificationImage)
                    passwordVerificationImage.isHidden = true
                    
                    // invalidate requirements
                    self.passwordRequirementVerified.append(false)
                    
                }
            default:
                break
            }
        } else {
            let longButtonHeight = self.view.frame.height * 0.0877
            
            self.selectedButtonView.backgroundColor = UIColor.wrGreen()
            self.selectedButtonView.layer.cornerRadius = longButtonHeight / 2
            self.selectedButtonView.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.27, width: self.standardWidth, height: longButtonHeight)
            self.selectedButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
            self.selectedButtonView.layer.shadowOpacity = 0.7
            self.selectedButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
            self.selectedButtonView.layer.shadowRadius = self.view.frame.height * 0.009
            newSignUpView.addSubview(self.selectedButtonView)
            
            self.rideButtonView.frame = self.selectedButtonView.frame
            newSignUpView.addSubview(self.rideButtonView)
            
            self.rideButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
            self.rideButtonLabel.textColor = UIColor.wrWhite()
            self.rideButtonLabel.textAlignment = NSTextAlignment.center
            self.rideButtonLabel.text = "get a ride to work"
            self.rideButtonLabel.frame.origin = CGPoint.zero
            self.rideButtonLabel.frame.size = self.rideButtonView.frame.size
            self.rideButtonView.addSubview(self.rideButtonLabel)
            
            self.rideButton.frame.origin = CGPoint.zero
            self.rideButton.frame.size = self.rideButtonView.frame.size
            self.rideButton.addTarget(self, action: #selector(SignUpViewController.getARideButtonPressed(_:)), for: .touchUpInside)
            self.rideButtonView.addSubview(self.rideButton)
            
            self.driveButtonView.frame.origin = CGPoint(x: self.rideButtonView.frame.origin.x, y: self.rideButtonView.frame.origin.y + (1.6 * longButtonHeight))
            self.driveButtonView.frame.size = self.selectedButtonView.frame.size
            newSignUpView.addSubview(self.driveButtonView)
            
            self.driveButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
            self.driveButtonLabel.textColor = UIColor.wrLightText()
            self.driveButtonLabel.textAlignment = NSTextAlignment.center
            self.driveButtonLabel.text = "drive others to work"
            self.driveButtonLabel.frame.origin = CGPoint.zero
            self.driveButtonLabel.frame.size = self.driveButtonView.frame.size
            self.driveButtonView.addSubview(self.driveButtonLabel)
            
            self.driveButton.frame.origin = CGPoint.zero
            self.driveButton.frame.size = self.rideButtonView.frame.size
            self.driveButton.addTarget(self, action: #selector(SignUpViewController.driveOthersButtonPressed(_:)), for: .touchUpInside)
            self.driveButtonView.addSubview(self.driveButton)
        }

        
        self.signUpMasterView.addSubview(newSignUpView)
    }
    
    func nextButtonPressed(_ sender: UIButton) {
        print("\n\nnext button pressed")

        
        print("current view index is \(self.currentViewIndex)")
        if self.currentViewIndex < 5 && self.currentViewIndex != 3 {
            
            self.textFields[self.currentViewIndex].resignFirstResponder()
            
            self.currentViewIndex += 1
            
            if self.currentViewIndex > self.maxViewIndex {
                self.setUpNewSignUpView(self.currentViewIndex)
                self.maxViewIndex = self.currentViewIndex
            }
            
            self.signUpViews[self.currentViewIndex].frame.origin.x = self.view.frame.width
            self.signUpViews[self.currentViewIndex].isHidden = false
            self.nextButton.isEnabled = false
            print("false from 390")
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.loadingBarView.frame.size.width = self.standardWidth * CGFloat(self.maxViewIndex + 1) / 6
                self.signUpViews[self.currentViewIndex - 1].frame.origin.x = -self.view.frame.width
                self.signUpViews[self.currentViewIndex].frame.origin.x = 0
                if self.currentViewIndex == 1 {
                    self.backButtonView.frame.origin.x = self.sideMargin
                }
            }, completion: { (finished) in
                self.signUpViews[self.currentViewIndex - 1].isHidden = true
                if self.currentViewIndex != 5 {
                    let newTFString = self.textFields[self.currentViewIndex].text
                    let charArray = Array(newTFString!.characters)
                    self.validateTextField(charArray)
                } else {
                    self.nextButton.isEnabled = true
                }
            })
        } else if self.currentViewIndex == 3 {
            self.textFields[self.currentViewIndex].resignFirstResponder()
            self.checkIfEmailIsFree()
        } else {
            self.view.addSubview(self.settingUpView)
            self.settingUpView.alpha = 0.0
            self.suSpinnerView.startAnimating()
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.signUpMasterView.alpha = 0.0
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.settingUpView.alpha = 1.0
                }, completion: { (finished) in
                    self.registerUser()
                })
            })
            
        }
        print("next button is enabled \(self.nextButton.isEnabled)")
    }
    
    func backButtonPressed(_ sender: UIButton) {
        print("back button pressed")
        
        self.currentViewIndex -= 1
        
        self.signUpViews[self.currentViewIndex].isHidden = false
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.loadingBarView.frame.size.width = self.standardWidth * CGFloat(self.maxViewIndex + 1) / 6
            self.signUpViews[self.currentViewIndex].frame.origin.x = 0
            self.signUpViews[self.currentViewIndex + 1].frame.origin.x = self.view.frame.width
            if self.currentViewIndex == 0 {
                self.backButtonView.frame.origin.x = -self.backButtonView.frame.width
            }
        }, completion: { (finished) in
            self.signUpViews[self.currentViewIndex + 1].isHidden = true
            let newTFString = self.textFields[self.currentViewIndex].text
            let charArray = Array(newTFString!.characters)
            self.validateTextField(charArray)
        })
    }
    
    func closeButtonPressed(_ sender: UIButton) {
        print("close button pressed")
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseIn, animations: {
            self.signUpMasterView.frame.origin.x = -self.view.frame.width
        }, completion: { (finished) in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    func getARideButtonPressed(_ sender: UIButton) {
        print("get a ride button pressed")
        self.isDriver = false
        
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.rideButtonLabel.textColor = UIColor.wrWhite()
            self.driveButtonLabel.textColor = UIColor.wrLightText()
            self.selectedButtonView.frame.origin.y = self.rideButtonView.frame.origin.y
        })
        
    }
    
    func driveOthersButtonPressed(_ sender: UIButton) {
        print("drive others button pressed")
        self.isDriver = true
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.rideButtonLabel.textColor = UIColor.wrLightText()
            self.driveButtonLabel.textColor = UIColor.wrWhite()
            self.selectedButtonView.frame.origin.y = self.driveButtonView.frame.origin.y
        })
    }
    
    
    
    func checkIfEmailIsFree() {
        print("checkIfEmailIsFree")
        self.emailCheckSpinnerView.startAnimating()
        self.emailCheckSpinnerView.isHidden = false
        self.alertMarks[3].isHidden = true
        self.alertLabels[3].isHidden = true
        self.validatedMarks[3].isHidden = true
        self.nextButton.isEnabled = false
        print("false from 491")
        Auth.auth().createUser(withEmail: self.textFields[3].text!, password: "Abc123") {
            (user, error) in
            if error != nil {
                print("error in sign up thrown")
                print(error ?? "")
                self.alertLabels[3].text = self.emailErrorDescriptors[(error?.localizedDescription)!]
                self.emailCheckSpinnerView.stopAnimating()
                self.emailCheckSpinnerView.isHidden = true
                self.alertMarks[3].isHidden = false
                self.alertLabels[3].isHidden = false
                self.validatedMarks[3].isHidden = true
                self.underlineViews[3].backgroundColor = UIColor.wrText()
                self.nextButton.isEnabled = true

            } else {
                
                print("user created\nuser UID: \(String(describing: user?.uid))")
                Auth.auth().currentUser?.delete(completion: { (error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    } else {
                        print("user deleted.")
                        
                        self.currentViewIndex += 1
                        
                        if self.currentViewIndex > self.maxViewIndex {
                            self.setUpNewSignUpView(self.currentViewIndex)
                            self.maxViewIndex = self.currentViewIndex
                        }
                        
                        self.emailCheckSpinnerView.stopAnimating()
                        self.emailCheckSpinnerView.isHidden = true
                        self.alertMarks[3].isHidden = true
                        self.alertLabels[3].isHidden = true
                        self.validatedMarks[3].isHidden = false
                        
                        self.signUpViews[self.currentViewIndex].frame.origin.x = self.view.frame.width
                        self.signUpViews[self.currentViewIndex].isHidden = false
                        self.nextButton.isEnabled = false
                        print("false from 531")
                        UIView.animate(withDuration: 0.369, delay: 0.9, options: .curveEaseInOut, animations: {
                            self.loadingBarView.frame.size.width = self.standardWidth * CGFloat(self.maxViewIndex + 1) / 6
                            self.signUpViews[self.currentViewIndex - 1].frame.origin.x = -self.view.frame.width
                            self.signUpViews[self.currentViewIndex].frame.origin.x = 0
                            
                        }, completion: { (finished) in
                            self.nextButton.isEnabled = true
                            self.signUpViews[self.currentViewIndex - 1].isHidden = true
                            if self.currentViewIndex != 4 {
                                let newTFString = self.textFields[self.currentViewIndex].text
                                let charArray = Array(newTFString!.characters)
                                self.validateTextField(charArray)
                            }
                        })
                    }
                })
            }
        }
    }
    
    func registerUser() {
        Auth.auth().createUser(withEmail: self.textFields[3].text!, password: self.textFields[4].text!) {
            (user, error) in
            if error != nil {
                print("error thrown\n\(String(describing: error))")
            } else {
                
                // sort entered name
                var usersNames: [String] = []
                var userFullName = self.textFields[0].text!
                var nameCharArray = Array(userFullName.characters)
                
                var nameStringToAppendChars = ""
                for index in 0..<nameCharArray.count {
                    let currentChar = nameCharArray[index]
                    
                    if String(currentChar) == " " {
                        usersNames.append(nameStringToAppendChars)
                        nameStringToAppendChars = ""
                    } else {
                        nameStringToAppendChars += String(currentChar)
                        if index == nameCharArray.count - 1 {
                            usersNames.append(nameStringToAppendChars)
                        }
                    }
                }
                
                // sort entered DOB
                let dobText = self.textFields[1].text!
                let dobCharArray = Array(dobText.characters)
                let dayString = "\(dobCharArray[0])\(dobCharArray[1])"
                let monthString = "\(dobCharArray[3])\(dobCharArray[4])"
                let yearString = "\(dobCharArray[6])\(dobCharArray[7])\(dobCharArray[8])\(dobCharArray[9])"
                let dobDay = Int(dayString)
                let dobMonth = Int(monthString)
                let dobYear = Int(yearString)
                
                CurrentUser.fullName = userFullName
                CurrentUser.firstName = usersNames.first!
                CurrentUser.lastName = usersNames.last!
                CurrentUser.email = self.textFields[3].text!
                CurrentUser.firebaseUID = (user?.uid)!
                CurrentUser.signedUpAsDriver = self.isDriver
                
                print(usersNames)
                
                
                // create user info data
                let dobInfo : [String : Any] = ["day":dobDay!,"month":dobMonth!,"year":dobYear!]
                let userInfoData: [String : Any] = ["quick":["firstname":usersNames.first!, "lastname":usersNames.last!, "activedriver":false],
                                               "signedupasdriver":self.isDriver,
                                               "fullname":userFullName,
                                               "email":CurrentUser.email,
                                               "phonenumber":"",
                                               "carmake":"",
                                               "carmodel":"",
                                               "carcolour":"",
                                               "caryear":0,
                                               "streetaddressa":"",
                                               "streetaddressb":"",
                                               "city":"",
                                               "province":"",
                                               "postalcode":"",
                                               "country":"",
                                               "businessuid":self.selectedBusiness.uid,
                                               "locationuid":self.selectedBusiness.allLocations[0].locationid,
                                               "dob":dobInfo
                                               ]
                
                // create pickup info data
                let pickupInfoData : [String : Any] = ["businessuid" : self.selectedBusiness.uid,
                                                       "businesslocationid":self.selectedBusiness.allLocations[0].locationid,
                                                       "firstname":usersNames.first!,
                                                       "isdriver":self.isDriver,
                                                       "fare":0,
                                                       "lat":42.304432,
                                                       "lng":-83.063892,
                                                       "seats":1
                                                      ]
                
                
                // add notification data
                let notificationRef = Database.database().reference().child("notifications").child("deviceid").child(CurrentUser.firebaseUID).child("token")
                notificationRef.setValue(CurrentUser.FirebaseInstanceToken)
                
                
                
                let ref = Database.database().reference()
                ref.child("users").child("userinfo").child((user?.uid)!).setValue(userInfoData)
                ref.child("users").child("pickupinfo").child((user?.uid)!).setValue(pickupInfoData)
                
                
                // create Stripe account
                var userIs = "rider"
                if self.isDriver { userIs = "driver" }
                let stripePostData : [String : Any] = ["email":CurrentUser.email,"firstname":CurrentUser.firstName,"lastname":CurrentUser.lastName,"uid":CurrentUser.firebaseUID, "dobday":dobDay!,"dobmonth":dobMonth!,"dobyear":dobYear!, "useris":userIs]
                
                let stripeSendURL = "http://workride.ca/payment/create-custom-acct.php"
                let stripeParams = stripePostData
                
                let stripeAcctManager = AFHTTPSessionManager()
                stripeAcctManager.post(stripeSendURL, parameters: stripeParams, success: { (operation, responseObject) -> Void in
                    if let response = responseObject as? [String : Any] {
                        print("\nresponse:\n\(response)")
                        let accountID = response["accountid"] as! String
                        Database.database().reference().child("users").child("financial").child(CurrentUser.firebaseUID).child("stripeaccountid").setValue(accountID)
                        
                        // accept Stripe tos
                        let stripePostData : [String : Any] = ["stripeid":accountID]
                        
                        let stripeSendURL = "http://workride.ca/payment/accept-tos.php"
                        let stripeParams = stripePostData
                        
                        let stripeAcctManager = AFHTTPSessionManager()
                        stripeAcctManager.post(stripeSendURL, parameters: stripeParams, success: { (operation, responseObject) -> Void in
                            if let response = responseObject as? [String : Any] {
                                print("\nresponse:\n\(response)")
                            }
                            
                        }) { (operation, error) -> Void in
                            print("failure operation:\n\(operation)")
                            print("\nerror:\n\(error)")
                        }
                    }
                }) { (operation, error) -> Void in
                    print("failure operation:\n\(operation)")
                    print("\nerror:\n\(error)")
                }
                
                
                // send welcome email
                let emailPOSTData : [String : Any] = ["firstName":CurrentUser.firstName, "email": CurrentUser.email]
                
                
                let emailSendURL = "http://workride.ca/email/send-welcome.php"
                let emailParams = emailPOSTData
                
                let emailManager = AFHTTPSessionManager()
                emailManager.post(emailSendURL, parameters: emailParams, success: { (operation, responseObject) -> Void in
                    if let response = responseObject as? [String : Any] {
                        print("\nresponse:\n\(response)")
                    }
                    
                }) { (operation, error) -> Void in
                    print("failure operation:\n\(operation)")
                    print("\nerror:\n\(error)")
                }
                
                
                // add to mailchimp list
                let mailchimpPOSTData : [String : Any] = ["firstName":usersNames.first!, "lastName":usersNames.last!, "email": CurrentUser.email]
                
                var sendToWho = "rider"
                if self.isDriver { sendToWho = "driver" }
                
                let sendURL = "http://connorholowachuk.com/workride/email/mailchimp/add-to-\(sendToWho)-list.php"
                let params = mailchimpPOSTData
                
                let manager = AFHTTPSessionManager()
                manager.post(sendURL, parameters: params, success: { (operation, responseObject) -> Void in
                    if let response = responseObject as? [String : Any] {
                        print("\nresponse:\n\(response)")
                    }
                    
                }) { (operation, error) -> Void in
                    print("failure operation:\n\(operation)")
                    print("\nerror:\n\(error)")
                }
                
                self.suSpinnerView.stopAnimating()
                self.moveToApp(isDriver: self.isDriver)
                
            }
        }
    }
    
    
    
    func validateTextField(_ charArray: [Character], originalString: String? = "") {
        
        var isValidated = false
        
        switch self.currentViewIndex {
        case 0:
            // validate name entries
            if charArray.count > 0 {
                var numberOfNames = 0
                var charsSinceSpace = 0
                var newNameAdded = false
                for index in 0...charArray.count - 1 {
                    
                    if charArray[index] != " " {
                        charsSinceSpace += 1
                        if charsSinceSpace >= 1 && newNameAdded == false {
                            numberOfNames += 1
                            newNameAdded = true
                        }
                        if charsSinceSpace <= 1 && newNameAdded == true {
                            numberOfNames -= 1
                            newNameAdded = false
                        }
                    } else {
                        charsSinceSpace = 0
                        newNameAdded = false
                    }
                }
                if numberOfNames >= 2 {
                    isValidated = true
                }
            }
        case 1:
            // validate dob
            if charArray.count == 10 {
                isValidated = true
            }
        case 2:
            // search for business
            if self.viewValidated[self.currentViewIndex] { isValidated = true }
            self.filtered = businessData.filter({ (text) -> Bool in
                let tmp: NSString = text as NSString
                let range = tmp.range(of: originalString!, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
            print(self.filtered)
            if self.filtered.count == 0 || charArray.count <= 1 {
                self.alertLabels[self.currentViewIndex].text = "No businesses match your search"
                self.alertLabels[self.currentViewIndex].isHidden = false
                self.businessSearchTableView.isHidden = true
                
                if keyboardReleaseEnabled == false {
                    self.keyboardReleaseGestureRecognizer = self.hideKeyboardWhenTappedAround()
                    keyboardReleaseEnabled = true
                }

            } else {
                self.alertLabels[self.currentViewIndex].isHidden = true
                self.alertMarks[self.currentViewIndex].isHidden = true
                self.businessSearchTableView.isHidden = false
                
                
                if keyboardReleaseEnabled {
                    self.view.removeGestureRecognizer(self.keyboardReleaseGestureRecognizer)
                    keyboardReleaseEnabled = false
                }
                
                self.filteredBusiness.removeAll()
                for i in 0..<self.searchableBizData.count {
                    for j in 0..<filtered.count {
                        if filtered[j] == self.searchableBizData[i].name {
                            let tempBiz = self.searchableBizData[i]
                            
                            if tempBiz.allLocations.count == 1 {
                                self.filteredBusiness.append(tempBiz)
                            } else {
                                for k in 0..<tempBiz.allLocations.count {
                                    let newBiz = Business()
                                    newBiz.name = tempBiz.name
                                    newBiz.uid = tempBiz.uid
                                    newBiz.allLocations = [tempBiz.allLocations[k]]
                                    self.filteredBusiness.append(newBiz)
                                }
                            }
                        }
                    }
                }
                self.businessSearchTableView.reloadData()
            }
        case 3:
            self.alertLabels[self.currentViewIndex].text = "please enter a valid email"
            if charArray.count > 0 {
                var containsAt = false
                var containsDot = false
                for index in 0...charArray.count - 1 {
                    let currentCharASCII = charArray[index].unicodeScalarCodePoint()
                    if currentCharASCII == 64 {containsAt = true}
                    if containsAt == true {
                        if currentCharASCII == 46 {containsDot = true}
                    }
                }
                if containsAt == true && containsDot == true {isValidated = true}
            }
        case 4:
            self.alertLabels[self.currentViewIndex].text = ""
            self.passwordRequirementVerified = [false, false, false]
            if charArray.count >= 6 {self.passwordRequirementVerified[0] = true}
            if charArray.count > 0 {
                for index in 0...charArray.count - 1 {
                    let currentCharASCII = charArray[index].unicodeScalarCodePoint()
                    if currentCharASCII >= 48 && currentCharASCII <= 57 {self.passwordRequirementVerified[2] = true}
                    if currentCharASCII >= 65 && currentCharASCII <= 90 {self.passwordRequirementVerified[1] = true}
                }
            }
            isValidated = true
            for index in 0...self.passwordRequirementMessages.count - 1 {
                if self.passwordRequirementVerified[index] == true {
                    self.passwordRequirementLabels[index].textColor = UIColor.wrGreen()
                    self.passwordRequirementImageViews[index].image = UIImage(named: "checkmark-small")
                } else {
                    isValidated = false
                    self.passwordRequirementLabels[index].textColor = UIColor.wrAlert()
                    self.passwordRequirementImageViews[index].image = UIImage(named: "alert-circle-small")
                }
            }
        default:
            break
        }
        
        if isValidated {
            print("page is validated")
            self.viewValidated[self.currentViewIndex] = true
            self.alertLabels[self.currentViewIndex].isHidden = true
            self.alertMarks[self.currentViewIndex].isHidden = true
            self.validatedMarks[self.currentViewIndex].isHidden = false
            self.nextButton.isEnabled = true
            self.nextButtonImageView.image = UIImage(named: "arrow-white")
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.nextButtonView.backgroundColor = UIColor.wrGreen()
                self.nextButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
                self.nextButtonView.layer.shadowOpacity = 0.7
                self.nextButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
                self.nextButtonView.layer.shadowRadius = self.view.frame.height * 0.009
                self.nextButtonView.layer.borderWidth = 0
                
                self.underlineViews[self.currentViewIndex].backgroundColor = UIColor.wrGreen()
            })
        } else {
            print("not valid")
            self.validatedMarks[self.currentViewIndex].isHidden = true
            self.viewValidated[self.currentViewIndex] = false
            self.nextButton.isEnabled = false
            print("false from 714")
            self.nextButtonImageView.image = UIImage(named: "arrow-gray")
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.nextButtonView.backgroundColor = UIColor.clear
                self.nextButtonView.layer.shadowOpacity = 0.0
                self.nextButtonView.layer.borderColor = UIColor.wrLightText().cgColor
                self.nextButtonView.layer.borderWidth = self.view.frame.width * 0.004
                
                self.underlineViews[self.currentViewIndex].backgroundColor = UIColor.wrText()
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textString = textField.text
        var charArray = Array(textString!.characters)
        if self.currentViewIndex == 4 && self.reEnteringPassword == true {
            charArray = []
            self.reEnteringPassword = false
        }
        let newCharArray = Array(string.characters)
        
        if string == "" {
            if charArray != [] {
                charArray.removeLast()
            }
        } else {
            for jIndex in 0...newCharArray.count - 1 {
                charArray.append(newCharArray[jIndex])
            }
            
        }
        
        switch self.currentViewIndex {
        case 1:
            print(charArray)
            
            if string != "" {
                if charArray.count == 2 || charArray.count == 5 {
                    self.textFields[self.currentViewIndex].text = "\(textField.text!)\(string)/"
                    return false
                }
            }
            
        case 2:
            if self.currentViewIndex == 2 { self.viewValidated[self.currentViewIndex] = false }
        case 4:
            for index in 0...self.passwordRequirementLabels.count - 1 {
                self.passwordRequirementLabels[index].isHidden = false
                self.passwordRequirementImageViews[index].isHidden = false
            }
        default:
            break
        }
        
        
        self.validateTextField(charArray, originalString: textString!)
        
        
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        
        return true
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            self.view.frame.origin.y = -self.view.frame.height * 0.33
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0.0
            
            if self.viewValidated[self.currentViewIndex] == false {
                self.alertLabels[self.currentViewIndex].isHidden = false
                self.alertMarks[self.currentViewIndex].isHidden = false
            }
        }
    }
    
    
    
    
    // table view methods
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection = \(self.filteredBusiness.count)")

        return self.filteredBusiness.count
    }
    
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("reloading cell \(indexPath.row)")
        // create a new cell if needed or reuse an old one
        let cell: businessSearchCell = self.businessSearchTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! businessSearchCell
        
        // set the text from the data model
        cell.nameLabel.text = self.filteredBusiness[indexPath.row].name
        cell.nameLabel.font = getFont(0, screenHeight: self.view.frame.height)
        cell.nameLabel.textColor = UIColor.wrText()
        cell.nameLabel.textAlignment = NSTextAlignment.left
        cell.nameLabel.frame = CGRect(x: 0, y: self.view.frame.height * 0.0225, width: standardWidth, height: standardLabelHeight)
        cell.addSubview(cell.nameLabel)
        
        cell.addressLabel.text = self.filteredBusiness[indexPath.row].allLocations[0].descriptor
        cell.addressLabel.font = getFont(2, screenHeight: self.view.frame.height)
        cell.addressLabel.textColor = UIColor.wrLightText()
        cell.addressLabel.textAlignment = NSTextAlignment.left
        cell.addressLabel.frame = CGRect(x: 0, y: cell.nameLabel.frame.origin.y + cell.nameLabel.frame.height, width: standardWidth, height: self.smallLabelHeight)
        cell.addSubview(cell.addressLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.118
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        self.selectedBusiness = self.filteredBusiness[indexPath.row]
        self.textFields[self.currentViewIndex].text = self.filteredBusiness[indexPath.row].name
        self.businessSearchTableView.isHidden = true
        self.alertLabels[self.currentViewIndex].isHidden = true
        self.alertMarks[self.currentViewIndex].isHidden = true
        self.textFields[self.currentViewIndex].resignFirstResponder()
        if keyboardReleaseEnabled == false {
            self.keyboardReleaseGestureRecognizer = self.hideKeyboardWhenTappedAround()
            keyboardReleaseEnabled = true
        }
        self.viewValidated[self.currentViewIndex] = true
        self.validateTextField([])
    }
    
    func moveToApp(isDriver: Bool) {
        self.wvNameLabel.text = CurrentUser.firstName
        self.view.addSubview(self.welcomeView)
        self.welcomeView.alpha = 0.0
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.settingUpView.alpha = 0.0
        }, completion: { (finished) in
            self.settingUpView.removeFromSuperview()
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.welcomeView.alpha = 1.0
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.369, delay: 2.0, options: .curveEaseInOut, animations: {
                    self.welcomeView.alpha = 0.0
                }, completion: { (finished) in
                    
                    let notificationRef = Database.database().reference().child("notifications").child("deviceid").child(CurrentUser.firebaseUID).child("token")
                    notificationRef.setValue(CurrentUser.FirebaseInstanceToken)
                    
                    let introVC = self.storyboard!.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    introVC.transitioningDelegate = self
                    self.present(introVC, animated: false, completion: nil)
                })
            })
        })
    }
    
    
}

class businessSearchCell: UITableViewCell {
    
    var nameLabel = UILabel()
    var addressLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


