//
//  IntroViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-29.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class IntroViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var masterContentView = UIView()
    
    var topTitleView = UIView()
    var topTitleWorkLabel = UILabel()
    var topTitleRideLabel = UILabel()
    
    let joinUsButtonView = UIView()
    let joinUsButtonLabel = UILabel()
    let joinUsButton = UIButton()
    
    let logInButtonView = UIView()
    let logInButtonLabel = UILabel()
    let logInButton = UIButton()
    
    var fromJoinUsButton = false
    
    var settingUpView = UIView()
    var suHeaderLabel = UILabel()
    var suSpinnerView = UIActivityIndicatorView()
    
    var welcomeView = UIView()
    var wvWelcomeLabel = UILabel()
    var wvNameLabel = UILabel()
    
    let scrollImageNames = ["intro-image-1", "intro-image-2", "intro-image-3"]
    let scrollText = ["join the community of workers just like you and get to work the green way.", "\nleave later by taking the quick way to work.", "get paid for every ride you give a coworker!"]
    var scrollImageContentViews : [UIView] = []
    var scrollImageViews : [UIImageView] = []
    var scrollImagesUnselectedDots : [UIView] = []
    let scrollImagesSelectedDot = UIView()
    let scrollView = UIScrollView()
    var currentImageIndex = 0
    var continueScrollingImages = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //important constant definitions
        let goldenRatio : CGFloat = 1.61803398875
        let textExtraSpaceFactor : CGFloat = 1.25
        let standardLabelHeight = self.view.frame.height * 0.03973013493 * textExtraSpaceFactor
        let smallLabelHeight = standardLabelHeight / goldenRatio * textExtraSpaceFactor
        let sideMargin = self.view.frame.width * 0.06
        let longButtonHeight = self.view.frame.height * 0.0877
        let longButtonWidth = self.view.frame.width * 0.65
        
        self.checkIfUserSignedIn()
        
        self.masterContentView.frame = self.view.frame
        self.view.addSubview(self.masterContentView)
        
        // top title view
        self.topTitleView.frame = CGRect(x: 0, y: self.view.frame.height * 0.0975, width: self.view.frame.width, height: standardLabelHeight)
        self.masterContentView.addSubview(self.topTitleView)
        
        self.topTitleWorkLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.topTitleWorkLabel.textColor = UIColor.wrText()
        self.topTitleWorkLabel.textAlignment = NSTextAlignment.right
        self.topTitleWorkLabel.text = "work"
        self.topTitleWorkLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: standardLabelHeight)
        self.topTitleView.addSubview(self.topTitleWorkLabel)
        
        self.topTitleRideLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.topTitleRideLabel.textColor = UIColor.wrGreen()
        self.topTitleRideLabel.textAlignment = NSTextAlignment.left
        self.topTitleRideLabel.text = "ride"
        self.topTitleRideLabel.frame = CGRect(x: self.view.frame.width / 2, y: 0, width: self.view.frame.width / 2, height: standardLabelHeight)
        self.topTitleView.addSubview(self.topTitleRideLabel)
        
        
        // scroll view
        let numberOfImages = self.scrollImageNames.count
        let circleViewWidth = self.view.frame.width * 0.0408
        let circleViewSpacing = circleViewWidth
        let totalCircleViewWidth = (circleViewWidth * CGFloat(numberOfImages)) + (circleViewSpacing * CGFloat(numberOfImages - 1))
        for index in 0..<numberOfImages {
            
            let newImageContentView = UIView()
            newImageContentView.frame = CGRect(x: 0, y: self.view.frame.height * 0.145, width: self.view.frame.width, height: self.view.frame.width)
            self.scrollImageContentViews.append(newImageContentView)
            self.masterContentView.addSubview(newImageContentView)
            
            let newImageView = UIImageView()
            newImageView.image = UIImage(named: self.scrollImageNames[index])
            newImageView.frame.size = newImageContentView.frame.size
            newImageView.frame.origin = CGPoint.zero
            self.scrollImageViews.append(newImageView)
            newImageContentView.addSubview(newImageView)
            
            
            let newTextView = UITextView()
            newTextView.font = getFont(2, screenHeight: self.view.frame.height)
            newTextView.textColor = UIColor.wrText()
            newTextView.backgroundColor = UIColor.clear
            newTextView.textAlignment = .center
            newTextView.isEditable = false
            newTextView.isSelectable = false
            newTextView.isScrollEnabled = false
            // newTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
            newTextView.text = self.scrollText[index]
            newTextView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.424, width: self.view.frame.width - (2 * sideMargin), height: standardLabelHeight * 3)
            newImageContentView.addSubview(newTextView)
            
            
            if index == 0 {
                
            } else {
                newImageContentView.frame.origin.x = self.view.frame.width
                newImageContentView.isHidden = true
            }
            
            
            
        }
        
        for index in 0..<numberOfImages {
            // set up unselected circle views
            
            let currentCircleViewXPosition = ((self.view.frame.width - totalCircleViewWidth) / 2) + ((circleViewWidth + circleViewSpacing) * CGFloat(index))
            
            let newUnselectedView = UIView()
            newUnselectedView.frame = CGRect(x: currentCircleViewXPosition, y: self.view.frame.height * 0.69, width: circleViewWidth, height: circleViewWidth)
            newUnselectedView.backgroundColor = UIColor.clear
            newUnselectedView.layer.borderColor = UIColor.wrLightText().cgColor
            newUnselectedView.layer.borderWidth = self.view.frame.width * 0.004
            newUnselectedView.layer.cornerRadius = circleViewWidth / 2
            self.masterContentView.addSubview(newUnselectedView)
            self.scrollImagesUnselectedDots.append(newUnselectedView)
        }
        
        self.scrollImagesSelectedDot.frame = CGRect(x: self.scrollImagesUnselectedDots[0].frame.origin.x, y: self.view.frame.height * 0.69, width: circleViewWidth, height: circleViewWidth)
        self.scrollImagesSelectedDot.backgroundColor = UIColor.wrGreen()
        self.scrollImagesSelectedDot.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.scrollImagesSelectedDot.layer.shadowOpacity = 0.3
        self.scrollImagesSelectedDot.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.scrollImagesSelectedDot.layer.shadowRadius = self.view.frame.height * 0.009
        self.scrollImagesSelectedDot.layer.cornerRadius = circleViewWidth / 2
        self.masterContentView.addSubview(self.scrollImagesSelectedDot)
        
        // join us button
        
        
        self.joinUsButtonView.backgroundColor = UIColor.wrGreen()
        self.joinUsButtonView.layer.cornerRadius = longButtonHeight / 2
        self.joinUsButtonView.frame = CGRect(x: (self.view.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.78, width: longButtonWidth, height: longButtonHeight)
        self.joinUsButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.joinUsButtonView.layer.shadowOpacity = 0.7
        self.joinUsButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.joinUsButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.masterContentView.addSubview(self.joinUsButtonView)

        
        self.joinUsButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.joinUsButtonLabel.textColor = UIColor.wrWhite()
        self.joinUsButtonLabel.textAlignment = NSTextAlignment.center
        self.joinUsButtonLabel.text = "join us"
        self.joinUsButtonLabel.frame.origin = CGPoint.zero
        self.joinUsButtonLabel.frame.size = self.joinUsButtonView.frame.size
        self.joinUsButtonView.addSubview(self.joinUsButtonLabel)
        
        self.joinUsButton.frame.origin = CGPoint.zero
        self.joinUsButton.frame.size = self.joinUsButtonView.frame.size
        self.joinUsButton.addTarget(self, action: #selector(IntroViewController.joinUsButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.joinUsButtonView.addSubview(self.joinUsButton)
        
        
        // log in button
        self.logInButtonView.frame.origin = CGPoint(x: self.joinUsButtonView.frame.origin.x, y: self.view.frame.height * 0.89)
        self.logInButtonView.frame.size = self.joinUsButtonView.frame.size
        self.masterContentView.addSubview(self.logInButtonView)
        
        self.logInButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.logInButtonLabel.textColor = UIColor.wrLightText()
        self.logInButtonLabel.textAlignment = NSTextAlignment.center
        self.logInButtonLabel.text = "log in"
        self.logInButtonLabel.frame.origin = CGPoint.zero
        self.logInButtonLabel.frame.size = self.logInButtonView.frame.size
        self.logInButtonView.addSubview(self.logInButtonLabel)
        
        self.logInButton.frame.origin = CGPoint.zero
        self.logInButton.frame.size = self.logInButtonView.frame.size
        self.logInButton.addTarget(self, action: #selector(IntroViewController.logInButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.logInButtonView.addSubview(self.logInButton)
        
        // setting up account view
        self.settingUpView.frame = self.view.frame
        
        self.suHeaderLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.suHeaderLabel.textColor = UIColor.wrText()
        self.suHeaderLabel.textAlignment = NSTextAlignment.center
        self.suHeaderLabel.text = "signing in..."
        self.suHeaderLabel.frame = CGRect(x: 0, y: self.view.frame.height * 0.576, width: self.view.frame.width, height: standardLabelHeight)
        self.settingUpView.addSubview(self.suHeaderLabel)
        
        let suSpinnerViewHeight = self.view.frame.height * 0.112
        self.suSpinnerView.frame = CGRect(x: (self.view.frame.width - suSpinnerViewHeight) / 2, y: self.view.frame.height * 0.375, width: suSpinnerViewHeight, height: suSpinnerViewHeight)
        self.suSpinnerView.color = UIColor.wrGreen()
        self.settingUpView.addSubview(self.suSpinnerView)
        
        
        // welcome view
        self.welcomeView.frame = self.view.frame
        
        self.wvWelcomeLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.wvWelcomeLabel.textColor = UIColor.wrText()
        self.wvWelcomeLabel.textAlignment = NSTextAlignment.center
        self.wvWelcomeLabel.text = "welcome back,"
        self.wvWelcomeLabel.frame = CGRect(x: 0, y: (self.view.frame.height / 2) - standardLabelHeight, width: self.view.frame.width, height: standardLabelHeight)
        self.welcomeView.addSubview(self.wvWelcomeLabel)
        
        self.wvNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.wvNameLabel.textColor = UIColor.wrText()
        self.wvNameLabel.textAlignment = NSTextAlignment.center
        self.wvNameLabel.text = "friend"
        self.wvNameLabel.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: standardLabelHeight)
        self.welcomeView.addSubview(self.wvNameLabel)
        
        
        
        self.masterContentView.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.masterContentView.isHidden = false
        if self.fromJoinUsButton {
            self.masterContentView.frame.origin.x = self.view.frame.width
        } else {
            self.masterContentView.frame.origin.x = -self.view.frame.width
        }
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseOut, animations: {
            self.masterContentView.frame.origin.x = 0
        })
        
        self.continueScrollingImages = true
        self.moveToNextImage()
    }
    
    func moveToNextImage() {
        if self.continueScrollingImages {
            var nextView = UIView()
            var nextCircleView = UIView()
            if self.currentImageIndex == self.scrollImageContentViews.count - 1 {
                // showing last image - move to first
                nextView = self.scrollImageContentViews[0]
                nextCircleView = self.scrollImagesUnselectedDots[0]
            } else {
                nextView = self.scrollImageContentViews[self.currentImageIndex + 1]
                nextCircleView = self.scrollImagesUnselectedDots[self.currentImageIndex + 1]
            }
            nextView.frame.origin.x = self.view.frame.width
            nextView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 6, options: .curveEaseInOut, animations: {
                self.scrollImageContentViews[self.currentImageIndex].frame.origin.x = -self.view.frame.width
                self.scrollImagesSelectedDot.frame.origin.x = nextCircleView.frame.origin.x
                nextView.frame.origin.x = 0
            }, completion: { (finished) in
                self.scrollImageContentViews[self.currentImageIndex].frame.origin.x = self.view.frame.width
                self.scrollImageContentViews[self.currentImageIndex].isHidden = true
                if self.currentImageIndex == self.scrollImageContentViews.count - 1 {
                    self.currentImageIndex = 0
                } else {
                    self.currentImageIndex += 1
                }
                self.moveToNextImage()
            })
        }
    }
    
    func joinUsButtonPressed(_ sender: UIButton) {
        print("join us button pressed")
        self.continueScrollingImages = false
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseIn, animations: {
            self.masterContentView.frame.origin.x = self.view.frame.width
        }, completion: { (finished) in
            self.fromJoinUsButton = true
            let introVC = self.storyboard!.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            introVC.transitioningDelegate = self
            self.present(introVC, animated: false, completion: nil)
        })
 
 /*
 
        let acct = STPBankAccount()
        let acctParams = STPBankAccountParams()
        acctParams.accountHolderName = "Connor Holowachuk"//CurrentUser.fullName
        acctParams.accountHolderType = .individual
        acctParams.currency = "CAD"
        acctParams.country = "CA"
        acctParams.routingNumber = "11000-000"
        acctParams.accountNumber = "000123456789"
        
        STPAPIClient.shared().createToken(withBankAccount: acctParams, completion: {
            (token, error) in
            
            if error != nil {
                print("error:\n\(error!)")
                
                return
            }
            print("token:\n\(token)")
            
            // set token for user external account
            let stripePostData : [String : Any] = ["stripeid":"acct_1AkvFrD4orhxG8ke", "accounttoken":token!.tokenId]
            
            let stripeSendURL = "http://workride.ca/payment/create-external-acct.php"
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
            
        })
        
        
        
         
         // accept Stripe tos
         let stripePostData : [String : Any] = ["stripeid":"acct_1AkvFrD4orhxG8ke"]
         
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
         
         // create Stripe account
         let userIs = "driver"
         let stripePostData : [String : Any] = ["email":"connor@workride.ca","firstname":"Connor","lastname":"Holowachuk","uid":"09FNiobeKsc6Ovx4Vsgoggo9XDa2", "dobday":2,"dobmonth":4,"dobyear":1995, "useris":userIs]
         
         let stripeSendURL = "http://workride.ca/payment/create-custom-acct.php"
         let stripeParams = stripePostData
         
         let stripeAcctManager = AFHTTPSessionManager()
         stripeAcctManager.post(stripeSendURL, parameters: stripeParams, success: { (operation, responseObject) -> Void in
         if let response = responseObject as? [String : Any] {
         print("\nresponse:\n\(response)")
         let accountID = response["accountid"] as! String
         FIRDatabase.database().reference().child("users").child("financial").child("09FNiobeKsc6Ovx4Vsgoggo9XDa2").child("stripeaccountid").setValue(accountID)
         }
         
         }) { (operation, error) -> Void in
         print("failure operation:\n\(operation)")
         print("\nerror:\n\(error)")
         }
         
         
        let userInfoDataA : [String : Any] = ["title" : "test title 5t", "body":"test body"]
        let userInfoDataB : [String : Any] = ["title" : "test title EU", "body":"test body"]
        let userInfoDataC : [String : Any] = ["title" : "test title eN", "body":"test body"]
        // 5t52sLW4qWZSBlvUY1melwJbVYH2
        // EU3uXvq8LrOwHmI23WFwMnUwUYP2
        // eNaciq5L5pPiH2cKLBh5J8RZee52
        let time = 434
        let ref = FIRDatabase.database().reference()
        ref.child("notifications").child("scheduled").child(time.description).child("5t52sLW4qWZSBlvUY1melwJbVYH2").setValue(userInfoDataA)
        ref.child("notifications").child("scheduled").child(time.description).child("EU3uXvq8LrOwHmI23WFwMnUwUYP2").setValue(userInfoDataB)
        ref.child("notifications").child("scheduled").child(time.description).child("eNaciq5L5pPiH2cKLBh5J8RZee52").setValue(userInfoDataC)
        
        
        let userInfoData: [String: Any] = ["quick":["firstname":"Matt", "lastname":"Example", "activedriver":false],
                                           "signedupasdriver":false,
                                           "fullname":"Sarah Example",
                                           "email":"example-matt@workride.ca",
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
                                           "businessuid":"qxLRmYVJ52ZXE0640m7DSUCInO22",
                                           "locationuid":"abc123"
        ]
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").child("userinfo").child("CG2tVZ9uiQOud1ifYuNsDo9ERR83").setValue(userInfoData)
       
        let pickupInfo: [String: Any] = ["lat":42.30868875720291,"lng":-83.06293845176697,"fare":300,"businessuid":"iYeV7pb4WhRt3LDeEO2so9i4sFD2","businesslocationid":"downtown-win","firstname":"Matt","isdriver":false,"seats":1]
        ref.child("users").child("pickupinfo").child("CG2tVZ9uiQOud1ifYuNsDo9ERR83").setValue(pickupInfo)
        
        
        
         

        
         
         
         let userInfoData: [String: Any] = ["businessname":"Starbucks",
         "primarycontactfirstname":"Connor",
         "primarycontactlastname":"Holowachuk",
         "phonenumber":"",
         "email":"example-starbucks@workride.ca",
         "primarylocationid":"downtown-win"]
         
         let ref = FIRDatabase.database().reference()
         ref.child("business").child("businessinfo").child("iYeV7pb4WhRt3LDeEO2so9i4sFD2").setValue(userInfoData)
         
         let ainfo: [String: Any] = ["info":["streetaddressa":"","streetaddressb":"","city":"Windsor","province":"ON","postalcode":"","country":"Canada"],"location":["lat":42.31741586639845,"lng":-83.03916871547699]]
         
         ref.child("business").child("locations").child("iYeV7pb4WhRt3LDeEO2so9i4sFD2").child("downtown-win").setValue(ainfo)
         
         ref.child("business").child("locations").child("iYeV7pb4WhRt3LDeEO2so9i4sFD2").child("maxcostperride").setValue(635)
         
         
         
        
         let userInfoData: [String: Any] = ["quick":["firstname":"testD", "lastname":"userD", "activedriver":true],
         "signedupasdriver":true,
         "fullname":"test user D",
         "email":"testuserd@gmail.com",
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
         "businessuid":"qxLRmYVJ52ZXE0640m7DSUCInO22",
         "locationuid":"abc123"
         ]
         
         let ref = FIRDatabase.database().reference()
         ref.child("users").child("userinfo").child("thPivAVbRbarhVPSAXYc5yi11Cr1").setValue(userInfoData)
         
         let riderInfoData: [String: Any] = [
         "driverlat":42.304427,
         "driverlng":-83.06386,
         "drivernormdist":50499,
         "drivernormtime":2605,
         "driveruid":"o6yMn4kfP8hXrOTI1OeOlKXcylu2",
         "leavetime":15169,
         "riders":[["lat":42.312862,"lng":-82.88612,"meettime":15173,"normdisttodeliver":432900,"normtimetodeliver":31,"uid":"QkwVZcLMz6MSnv1tRXn2skrQykV2"],
         ["lat":42.29051,"lng":-83.076322,"meettime":15150,"normdisttodeliver":49900,"normtimetodeliver":39,"uid":"QkwVZcLMz6MSnv1tRXn2skrQykV2"]],
         "totalseats":3
         ]
         
         let otherRiderInfoData: [String: Any] = [
         "driverlat":42.32619,
         "driverlng":-82.98917,
         "drivernormdist":50400,
         "drivernormtime":43,
         "driveruid":"thPivAVbRbarhVPSAXYc5yi11Cr1",
         "leavetime":15169,
         "totalseats":2
         ]
         
         
        */
    }
    
    func logInButtonPressed(_ sender: UIButton) {
        print("log in button pressed")
        self.continueScrollingImages = false
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseIn, animations: {
            self.masterContentView.frame.origin.x = -self.view.frame.width
        }, completion: { (finished) in
            self.fromJoinUsButton = false
            let introVC = self.storyboard!.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            introVC.transitioningDelegate = self
            self.present(introVC, animated: false, completion: nil)
        })
    }
    
    func checkIfUserSignedIn() {
        var timesThrough = 0
        Auth.auth().addStateDidChangeListener { auth, user in
            if timesThrough == 0 {
                timesThrough = 1
                if let user = user {
                    print(user.uid as Any)
                    
                    self.view.addSubview(self.settingUpView)
                    self.settingUpView.alpha = 0.0
                    self.suSpinnerView.startAnimating()
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.masterContentView.alpha = 0.0
                        self.settingUpView.alpha = 1.0
                    }, completion: { (finished) in
                        let userinfoRef = Database.database().reference().child("users").child("userinfo").child(user.uid)
                        userinfoRef.observeSingleEvent(of: .value, with: {  (snapshot) in
                            
                            if snapshot.exists() {
                                let userinfoData = snapshot.value as? NSDictionary
                                let quickInfoData = userinfoData?["quick"] as? NSDictionary
                                
                                CurrentUser.firebaseUID = user.uid
                                
                                CurrentUser.firstName = (quickInfoData?["firstname"] as? String)!
                                CurrentUser.lastName = (quickInfoData?["lastname"] as? String)!
                                CurrentUser.fullName = (userinfoData?["fullname"] as? String)!
                                
                                CurrentUser.email = (userinfoData?["email"] as? String)!
                                
                                CurrentUser.isActiveDriver =  (quickInfoData?["activedriver"] as? Bool)!
                                CurrentUser.signedUpAsDriver = (userinfoData?["signedupasdriver"] as? Bool)!
                                
                                CurrentUser.streetAddressA = (userinfoData?["streetaddressa"] as? String)!
                                CurrentUser.streetAddressB = (userinfoData?["streetaddressb"] as? String)!
                                CurrentUser.city = (userinfoData?["city"] as? String)!
                                CurrentUser.country = (userinfoData?["country"] as? String)!
                                CurrentUser.postalCode = (userinfoData?["postalcode"] as? String)!
                                
                                CurrentUser.business.uid = (userinfoData?["businessuid"] as? String)!
                                CurrentUser.business.locationid = (userinfoData?["locationuid"] as? String)!
                                
                                // get pickup location
                                let pickupLocRef = Database.database().reference().child("users").child("pickupinfo").child(CurrentUser.firebaseUID)
                                pickupLocRef.observeSingleEvent(of: .value, with: {  (pickupLocSnapshot) in
                                    
                                    let pickupLocData = pickupLocSnapshot.value as? NSDictionary
                                    CurrentUser.pickupLocation.latitude = CLLocationDegrees((pickupLocData?["lat"] as? Float)!)
                                    CurrentUser.pickupLocation.longitude = CLLocationDegrees((pickupLocData?["lng"] as? Float)!)
                                    
                                    if CurrentUser.signedUpAsDriver {
                                        CurrentUser.seats = (pickupLocData?["seats"] as? Int)!
                                        let bizMaxFareRef = Database.database().reference().child("business").child("fare").child(CurrentUser.business.uid)
                                        bizMaxFareRef.observeSingleEvent(of: .value, with: {  (bizFareSnapshot) in
                                            let bizFareData = bizFareSnapshot.value as? NSDictionary
                                            let maxFare = (bizFareData?["maxcostperride"] as? Int)!
                                            
                                            let maxPayment = Int(Double(maxFare) * Double(CurrentUser.seats) * 0.9 / 2)
                                            CurrentUser.fare = maxPayment
                                        })
                                    } else {
                                        CurrentUser.fare = (pickupLocData?["fare"] as? Int)!
                                    }
                                })
                                
                                
                                // get financial info
                                let financialRef = Database.database().reference().child("users").child("financial").child(CurrentUser.firebaseUID)
                                financialRef.observeSingleEvent(of: .value, with: {  (finSnapshot) in
                                    if finSnapshot.hasChild("stripeaccountid") {
                                        let finInfoData = finSnapshot.value as? NSDictionary
                                        CurrentUser.stripeAccountID = (finInfoData?["stripeaccountid"] as? String)!
                                    }
                                    if finSnapshot.hasChild("lastfourdigits") {
                                        let finInfoData = finSnapshot.value as? NSDictionary
                                        CurrentUser.lastFourDigits = (finInfoData?["lastfourdigits"] as? String)!
                                    }
                                    if finSnapshot.hasChild("hasUploadedIDNumber") {
                                        let finInfoData = finSnapshot.value as? NSDictionary
                                        CurrentUser.hasUploadedIDNumber = (finInfoData?["hasUploadedIDNumber"] as? Bool)!
                                    }
                                    if finSnapshot.hasChild("hasUploadedIDDocument") {
                                        let finInfoData = finSnapshot.value as? NSDictionary
                                        CurrentUser.hasUploadedIDDocument = (finInfoData?["hasUploadedIDDocument"] as? Bool)!
                                    }
                                })
                                
                                // get business info
                                let businessRef = Database.database().reference().child("business").child("businessinfo").child(CurrentUser.business.uid)
                                businessRef.observeSingleEvent(of: .value, with: {  (bizSnapshot) in
                                
                                    let bizInfoData = bizSnapshot.value as? NSDictionary
                                    CurrentUser.business.name = (bizInfoData?["businessname"] as? String)!
                                    
                                })
                                
                                // get business location
                                let businessLocRef = Database.database().reference().child("business").child("locations").child(CurrentUser.business.uid).child(CurrentUser.business.locationid).child("location")
                                businessLocRef.observeSingleEvent(of: .value, with: {  (bizLocSnapshot) in
                                    
                                    let bizLocData = bizLocSnapshot.value as? NSDictionary
                                    CurrentUser.business.location.latitude = CLLocationDegrees((bizLocData?["lat"] as? Float)!)
                                    CurrentUser.business.location.longitude = CLLocationDegrees((bizLocData?["lng"] as? Float)!)
                                })
                                
                                var doneLoadingData = false
                                var doneLoadingPic = false
                                // get schedule data
                                let currentDate = Date()
                                let currentYear = currentDate.year()
                                let currentMonth = currentDate.month()
                                
                                let currentMonthRef = Database.database().reference().child("users").child("schedule").child(CurrentUser.firebaseUID).child(currentYear.description).child(currentMonth.description).observeSingleEvent(of: .value, with: {  (schedSnapshot) in
                                    let dataExists = schedSnapshot.exists()
                                    
                                    if dataExists {
                                        let schedData = (schedSnapshot.value as? NSDictionary)!
                                        
                                        /* schedData = [26:[from:[id:"",ismatched:false,time:14260],
                                         to:[id:"",ismatched:false,time:14260]],
                                         27:[from:[id:"",ismatched:false,time:14260],
                                         to:[id:"",ismatched:false,time:14260]],
                                         ]
                                         */
                                        
                                        CurrentUser.schedule = [currentYear:[currentMonth:[:]]]
                                        
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
                                                        newRider.fare = (newRiderData["fare"] as? Int)!
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
                                                        let currentYearData : [Int : Any] = [currentMonth : schedForMonth]
                                                        CurrentUser.schedule[currentYear] = currentYearData
                                                        print(CurrentUser.schedule)
                                                        self.suSpinnerView.stopAnimating()
                                                        self.moveToApp(isDriver: CurrentUser.signedUpAsDriver)
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
                                                        newRider.fare = (newRiderData["fare"] as? Int)!
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
                                                        let currentYearData : [Int : Any] = [currentMonth : schedForMonth]
                                                        CurrentUser.schedule[currentYear] = currentYearData
                                                        print(CurrentUser.schedule)
                                                        self.suSpinnerView.stopAnimating()
                                                        self.moveToApp(isDriver: CurrentUser.signedUpAsDriver)
                                                    }
                                                }
                                            })
                                        }
                                    } else {
                                        // no data exists for this month - continue to app
                                        if doneLoadingPic == true {
                                            self.suSpinnerView.stopAnimating()
                                            self.moveToApp(isDriver: CurrentUser.signedUpAsDriver)
                                        } else {
                                            doneLoadingData = true
                                        }
                                    }
                                })
                                
                                let profilePhotoURL = user.photoURL
                                
                                if profilePhotoURL != nil {
                                    print("image URL not nil\n")
                                    let storage = Storage.storage()
                                    let storageRef = storage.reference(forURL: "gs://workride-dc700.appspot.com")
                                    let userImageRef = storageRef.child("userImages").child("driver").child(CurrentUser.firebaseUID).child("profileImage").child("image.jpg")
                                    
                                    print(profilePhotoURL?.absoluteString)
                                    
                                    userImageRef.downloadURL() {
                                        (URL, error) -> Void in
                                        
                                        if error != nil {
                                            print("\(error.debugDescription)\n")
                                        } else {
                                            
                                            let imageData: NSData = NSData.init(contentsOf: URL!)!
                                            let profileImage: UIImage = UIImage(data: imageData as Data)!
                                            CurrentUser.profileImage = profileImage
                                            if doneLoadingData == false {
                                                print("done loading pic\n")
                                                doneLoadingPic = true
                                            } else {
                                                print("\ntransitioning from image w/ user image\n\n")
                                                self.suSpinnerView.stopAnimating()
                                                self.moveToApp(isDriver: CurrentUser.signedUpAsDriver)
                                            }
                                        }
                                    }
                                } else {
                                    print("image URL is nil\n")
                                    CurrentUser.profileImage = UIImage(named: "generic-profile-image")
                                    if doneLoadingData == false {
                                        print("done loading pic - pic is nil\n")
                                        doneLoadingPic = true
                                    } else {
                                        print("\ntransitioning from image w/o user image\n\n")
                                        self.suSpinnerView.stopAnimating()
                                        self.moveToApp(isDriver: CurrentUser.signedUpAsDriver)
                                    }
                                }
                                
                                
                                
                            }
                            
                        })
                    })
                }
            }
        }
    }
    
    func moveToApp(isDriver: Bool) {
        self.continueScrollingImages = false
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
                    //let introVC = self.storyboard!.instantiateViewController(withIdentifier: "RoutesViewController") as! RoutesViewController
                    introVC.transitioningDelegate = self
                    self.present(introVC, animated: false, completion: nil)
                })
            })
        })
    }
    
    
}
