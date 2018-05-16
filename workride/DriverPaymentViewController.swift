//
//  DriverPaymentViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-07-30.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class DriverPaymentViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate {
    
    
    //important constant definitions
    let goldenRatio : CGFloat = 1.61803398875
    let textExtraSpaceFactor : CGFloat = 1.25
    var standardLabelHeight: CGFloat = 0.0
    var smallLabelHeight: CGFloat = 0.0
    var sideMargin: CGFloat = 0.0
    var standardWidth: CGFloat = 0.0
    
    var masterContentView = UIView()
    let accountInfoView = UIView()
    let SINView = UIView()
    let legalDocView = UIView()
    let completeView = UIView()
    var allViews : [UIView] = []
    
    
    // account info view subviews
    let accountInfoDescriptorTextView = UITextView()
    
    let accountNumberTextField = UITextField()
    let accountNumberAlertLabel = UILabel()
    let accountNumberStatusImageView = UIImageView()
    var accountNumberVerified = false
    
    let institutionNumberTextField = UITextField()
    let institutionNumberAlertLabel = UILabel()
    let institutionNumberStatusImageView = UIImageView()
    var institutionNumberVerified = false
    
    let transitNumberTextField = UITextField()
    let transitNumberAlertLabel = UILabel()
    let transitNumberStatusImageView = UIImageView()
    var transitNumberVerified = false
    
    // SIN view subviews
    let sinInfoDescriptorTextView = UITextView()
    
    let SINTextField = UITextField()
    let SINAlertLabel = UILabel()
    let SINStatusImageView = UIImageView()
    var SINVerified = false
    
    
    var signInALabel = UILabel()
    var signInBLabel = UILabel()
    var loadingBarView = UIView()
    
    var closeButtonView = UIView()
    var closeButtonImageView = UIImageView()
    var closeButton = UIButton()
    
    let nextButtonLabel = UILabel()
    let nextButton = UIButton()
    let nextSpinner = UIActivityIndicatorView()
    var pageIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        
        
        let subViewHeight = self.view.frame.height * 0.595
        let subViewYPosition = self.view.frame.height * 0.281
        
        // set up master content view
        self.masterContentView.frame = self.view.frame
        self.view.addSubview(self.masterContentView)
        
        self.allViews = [self.accountInfoView, self.SINView, self.legalDocView, self.completeView]
        
        self.loadingBarView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.145, width: standardWidth / 5, height: self.view.frame.height * 0.0051)
        self.loadingBarView.backgroundColor = UIColor.wrGreen()
        self.masterContentView.addSubview(self.loadingBarView)
        
        self.signInALabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.signInALabel.textColor = UIColor.wrText()
        self.signInALabel.textAlignment = NSTextAlignment.left
        self.signInALabel.text = "setup your payment"
        self.signInALabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.17, width: standardWidth, height: standardLabelHeight)
        self.masterContentView.addSubview(self.signInALabel)
        
        self.signInBLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.signInBLabel.textColor = UIColor.wrText()
        self.signInBLabel.textAlignment = NSTextAlignment.left
        self.signInBLabel.text = "infromation."
        self.signInBLabel.frame = CGRect(x: sideMargin, y: self.signInALabel.frame.origin.y + self.signInALabel.frame.height, width: standardWidth, height: standardLabelHeight)
        self.masterContentView.addSubview(self.signInBLabel)
        
        
        let closeButtonHeight = self.view.frame.height * 0.045
        self.closeButtonView.frame = CGRect(x: self.view.frame.width - sideMargin - closeButtonHeight, y: self.view.frame.height * 0.0915, width: closeButtonHeight, height: closeButtonHeight)
        self.masterContentView.addSubview(self.closeButtonView)
        
        self.closeButtonImageView.frame.origin = CGPoint.zero
        self.closeButtonImageView.frame.size = self.closeButtonView.frame.size
        self.closeButtonImageView.image = UIImage(named: "close")
        self.closeButtonView.addSubview(self.closeButtonImageView)
        
        self.closeButton.frame.origin = CGPoint.zero
        self.closeButton.frame.size = self.closeButtonView.frame.size
        self.closeButton.addTarget(self, action: #selector(SignInViewController.closeButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.closeButtonView.addSubview(self.closeButton)
        
        
        
        // set up account info view
        self.accountInfoView.frame = CGRect(x: 0, y: subViewYPosition, width: self.view.frame.width, height: subViewHeight)
        self.masterContentView.addSubview(self.accountInfoView)
        
        self.accountInfoDescriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
        self.accountInfoDescriptorTextView.textColor = UIColor.wrText()
        self.accountInfoDescriptorTextView.textAlignment = .left
        self.accountInfoDescriptorTextView.text = "direct deposit information can be found on bank statements and cheques associated with your account"
        self.accountInfoDescriptorTextView.frame = CGRect(x: self.sideMargin, y: self.view.frame.height / 30, width: self.standardWidth * 1.1, height: self.view.frame.height * 0.15)
        self.accountInfoDescriptorTextView.isEditable = false
        self.accountInfoDescriptorTextView.isSelectable = false
        self.accountInfoDescriptorTextView.isScrollEnabled = false
        self.accountInfoDescriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        self.accountInfoView.addSubview(self.accountInfoDescriptorTextView)
        
        self.accountNumberTextField.text = ""
        self.accountNumberTextField.delegate = self
        self.accountNumberTextField.font = getFont(0, screenHeight: self.view.frame.height)
        self.accountNumberTextField.textColor = UIColor.wrText()
        self.accountNumberTextField.autocapitalizationType = .none
        self.accountNumberTextField.autocorrectionType = .no
        self.accountNumberTextField.keyboardType = .numberPad
        self.accountNumberTextField.adjustsFontSizeToFitWidth = true
        self.accountNumberTextField.attributedPlaceholder = NSAttributedString(string: "account number", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
        self.accountNumberTextField.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.21, width: self.standardWidth * 0.9, height: self.standardLabelHeight)
        self.accountInfoView.addSubview(self.accountNumberTextField)
        
        let alertMarkImageViewHeight = self.view.frame.height * 0.03
        self.accountNumberStatusImageView.frame = CGRect(x: self.accountNumberTextField.frame.origin.x + self.accountNumberTextField.frame.width, y: self.accountNumberTextField.frame.origin.y + ((self.accountNumberTextField.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
        self.accountNumberStatusImageView.image = UIImage(named: "alert-mark")
        self.accountNumberStatusImageView.isHidden = true
        self.accountInfoView.addSubview(self.accountNumberStatusImageView)
        
        self.accountNumberAlertLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.accountNumberAlertLabel.textColor = UIColor.wrAlert()
        self.accountNumberAlertLabel.textAlignment = NSTextAlignment.left
        self.accountNumberAlertLabel.text = "must be between 7 and 11 digits"
        self.accountNumberAlertLabel.frame = CGRect(x: self.sideMargin, y: self.accountNumberTextField.frame.origin.y + self.accountNumberTextField.frame.height, width: self.accountNumberTextField.frame.width, height: standardLabelHeight)
        self.accountNumberAlertLabel.isHidden = true
        self.accountInfoView.addSubview(self.accountNumberAlertLabel)
        
        
        
        self.institutionNumberTextField.text = ""
        self.institutionNumberTextField.delegate = self
        self.institutionNumberTextField.font = getFont(0, screenHeight: self.view.frame.height)
        self.institutionNumberTextField.textColor = UIColor.wrText()
        self.institutionNumberTextField.autocapitalizationType = .none
        self.institutionNumberTextField.autocorrectionType = .no
        self.institutionNumberTextField.keyboardType = .numberPad
        self.institutionNumberTextField.adjustsFontSizeToFitWidth = true
        self.institutionNumberTextField.attributedPlaceholder = NSAttributedString(string: "institution number", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
        self.institutionNumberTextField.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.361, width: self.standardWidth * 0.9, height: self.standardLabelHeight)
        self.accountInfoView.addSubview(self.institutionNumberTextField)
        
        self.institutionNumberStatusImageView.frame = CGRect(x: self.institutionNumberTextField.frame.origin.x + self.institutionNumberTextField.frame.width, y: self.institutionNumberTextField.frame.origin.y + ((self.institutionNumberTextField.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
        self.institutionNumberStatusImageView.image = UIImage(named: "alert-mark")
        self.institutionNumberStatusImageView.isHidden = true
        self.accountInfoView.addSubview(self.institutionNumberStatusImageView)
        
        self.institutionNumberAlertLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.institutionNumberAlertLabel.textColor = UIColor.wrAlert()
        self.institutionNumberAlertLabel.textAlignment = NSTextAlignment.left
        self.institutionNumberAlertLabel.text = "must be 3 digits long"
        self.institutionNumberAlertLabel.frame = CGRect(x: self.sideMargin, y: self.institutionNumberTextField.frame.origin.y + self.institutionNumberTextField.frame.height, width: self.institutionNumberTextField.frame.width, height: standardLabelHeight)
        self.institutionNumberAlertLabel.isHidden = true
        self.accountInfoView.addSubview(self.institutionNumberAlertLabel)
        
        
        self.transitNumberTextField.text = ""
        self.transitNumberTextField.delegate = self
        self.transitNumberTextField.font = getFont(0, screenHeight: self.view.frame.height)
        self.transitNumberTextField.textColor = UIColor.wrText()
        self.transitNumberTextField.autocapitalizationType = .none
        self.transitNumberTextField.autocorrectionType = .no
        self.transitNumberTextField.keyboardType = .numberPad
        self.transitNumberTextField.adjustsFontSizeToFitWidth = true
        self.transitNumberTextField.attributedPlaceholder = NSAttributedString(string: "transit number", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
        self.transitNumberTextField.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.495, width: self.standardWidth * 0.9, height: self.standardLabelHeight)
        self.accountInfoView.addSubview(self.transitNumberTextField)
        
        self.transitNumberStatusImageView.frame = CGRect(x: self.transitNumberTextField.frame.origin.x + self.transitNumberTextField.frame.width, y: self.transitNumberTextField.frame.origin.y + ((self.transitNumberTextField.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
        self.transitNumberStatusImageView.image = UIImage(named: "alert-mark")
        self.transitNumberStatusImageView.isHidden = true
        self.accountInfoView.addSubview(self.transitNumberStatusImageView)
        
        self.transitNumberAlertLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.transitNumberAlertLabel.textColor = UIColor.wrAlert()
        self.transitNumberAlertLabel.textAlignment = NSTextAlignment.left
        self.transitNumberAlertLabel.text = "must be 5 digits long"
        self.transitNumberAlertLabel.frame = CGRect(x: self.sideMargin, y: self.transitNumberTextField.frame.origin.y + self.transitNumberTextField.frame.height, width: self.transitNumberTextField.frame.width, height: standardLabelHeight)
        self.transitNumberAlertLabel.isHidden = true
        self.accountInfoView.addSubview(self.transitNumberAlertLabel)

        
        
        // set up next button
        self.nextButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.nextButtonLabel.textColor = UIColor.wrLightText()
        self.nextButtonLabel.textAlignment = .right
        self.nextButtonLabel.text = "next"
        self.nextButtonLabel.frame = CGRect(x: self.view.frame.width - self.sideMargin - (self.view.frame.width / 2), y: subViewYPosition + subViewHeight, width: self.view.frame.width / 2, height: self.standardLabelHeight)
        self.masterContentView.addSubview(self.nextButtonLabel)
        
        self.nextButton.frame = CGRect(x: self.nextButtonLabel.frame.origin.x, y: self.nextButtonLabel.frame.origin.y, width: self.view.frame.width - self.nextButtonLabel.frame.origin.x, height: self.view.frame.height - self.nextButtonLabel.frame.origin.y)
        self.nextButton.addTarget(self, action: #selector(DriverPaymentViewController.nextButtonPressed(_:)), for: .touchUpInside)
        self.nextButton.isEnabled = false
        self.masterContentView.addSubview(self.nextButton)
        
        let spinnerWidth = self.standardLabelHeight
        self.nextSpinner.frame = CGRect(x: self.view.frame.width - self.sideMargin - spinnerWidth, y: self.nextButtonLabel.frame.origin.y, width: spinnerWidth, height: spinnerWidth)
        self.nextSpinner.hidesWhenStopped = true
        self.nextSpinner.color = UIColor.wrGreen()
        self.masterContentView.addSubview(self.nextSpinner)
        
    }
    
    
    func nextButtonPressed(_ sender: UIButton) {
        print("next button pressed")
        
        switch self.pageIndex {
        case 0:
            print("0")
            self.nextButtonLabel.isHidden = true
            self.nextButton.isEnabled = false
            self.nextSpinner.startAnimating()
            self.setupAccount()
        case 1:
            print("0")
            self.nextButtonLabel.isHidden = true
            self.nextButton.isEnabled = false
            self.nextSpinner.startAnimating()
            self.setSINNumber()
        default:
            break
        }
    }
    
    
    func closeButtonPressed(_ sender: UIButton) {
        print("close button pressed")
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseIn, animations: {
            
        }, completion: { (finished) in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    
    func moveToNextView() {
        
        var nextViewIndex = 3
        if CurrentUser.hasUploadedIDNumber == false {nextViewIndex = 1} else if CurrentUser.hasUploadedIDDocument == false {nextViewIndex = 2}
        let subViewHeight = self.view.frame.height * 0.595
        let subViewYPosition = self.view.frame.height * 0.281
        
        switch nextViewIndex {
        case 1:
            print("presenting SIN view")
            // set up account info view
            self.SINView.frame = CGRect(x: self.view.frame.width, y: subViewYPosition, width: self.view.frame.width, height: subViewHeight)
            self.masterContentView.addSubview(self.SINView)
            
            self.sinInfoDescriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
            self.sinInfoDescriptorTextView.textColor = UIColor.wrText()
            self.sinInfoDescriptorTextView.textAlignment = .left
            self.sinInfoDescriptorTextView.text = "In order to process payouts in Canada, workride must request your SIN"
            self.sinInfoDescriptorTextView.frame = CGRect(x: self.sideMargin, y: self.view.frame.height / 30, width: self.standardWidth * 1.1, height: self.view.frame.height * 0.15)
            self.sinInfoDescriptorTextView.isEditable = false
            self.sinInfoDescriptorTextView.isSelectable = false
            self.sinInfoDescriptorTextView.isScrollEnabled = false
            self.sinInfoDescriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
            self.SINView.addSubview(self.sinInfoDescriptorTextView)
            
            self.SINTextField.text = ""
            self.SINTextField.delegate = self
            self.SINTextField.font = getFont(0, screenHeight: self.view.frame.height)
            self.SINTextField.textColor = UIColor.wrText()
            self.SINTextField.autocapitalizationType = .none
            self.SINTextField.autocorrectionType = .no
            self.SINTextField.keyboardType = .numberPad
            self.SINTextField.adjustsFontSizeToFitWidth = true
            self.SINTextField.attributedPlaceholder = NSAttributedString(string: "SIN", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
            self.SINTextField.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.21, width: self.standardWidth * 0.9, height: self.standardLabelHeight)
            self.SINView.addSubview(self.SINTextField)
            
            let alertMarkImageViewHeight = self.view.frame.height * 0.03
            self.SINStatusImageView.frame = CGRect(x: self.accountNumberTextField.frame.origin.x + self.accountNumberTextField.frame.width, y: self.accountNumberTextField.frame.origin.y + ((self.accountNumberTextField.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
            self.SINStatusImageView.image = UIImage(named: "alert-mark")
            self.SINStatusImageView.isHidden = true
            self.SINView.addSubview(self.SINStatusImageView)
            
            self.SINAlertLabel.font = getFont(2, screenHeight: self.view.frame.height)
            self.SINAlertLabel.textColor = UIColor.wrAlert()
            self.SINAlertLabel.textAlignment = NSTextAlignment.left
            self.SINAlertLabel.text = "SIN's are 9 digits long"
            self.SINAlertLabel.frame = CGRect(x: self.sideMargin, y: self.accountNumberTextField.frame.origin.y + self.accountNumberTextField.frame.height, width: self.accountNumberTextField.frame.width, height: standardLabelHeight)
            self.SINAlertLabel.isHidden = true
            self.SINView.addSubview(self.SINAlertLabel)
            
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.allViews[self.pageIndex].frame.origin.x = -self.view.frame.width
                self.allViews[nextViewIndex].frame.origin.x = 0
            }, completion: { (finished) in
                self.nextButtonLabel.textColor = UIColor.wrLightText()
                self.nextButton.isEnabled = true
                self.pageIndex = nextViewIndex
            })
            
        case 2:
            print("presenting ID document view")
            
            nextViewIndex = 3
            
            
            // email sent view
            self.completeView.frame = self.view.frame
            self.completeView.frame.origin.x = self.view.frame.width
            self.view.addSubview(self.completeView)
            
            let esCheckMarkImageHeight = self.view.frame.height * 0.255
            let esCheckMarkImageView = UIImageView()
            esCheckMarkImageView.frame = CGRect(x: (self.view.frame.width - esCheckMarkImageHeight) / 2, y: self.view.frame.height * 0.198, width: esCheckMarkImageHeight, height: esCheckMarkImageHeight)
            esCheckMarkImageView.image = UIImage(named: "checkmark-large")
            self.completeView.addSubview(esCheckMarkImageView)
            
            let esHeaderLabel = UILabel()
            esHeaderLabel.font = getFont(1, screenHeight: self.view.frame.height)
            esHeaderLabel.textColor = UIColor.wrText()
            esHeaderLabel.textAlignment = NSTextAlignment.center
            esHeaderLabel.text = "complete!"
            esHeaderLabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.471, width: standardWidth, height: standardLabelHeight)
            self.completeView.addSubview(esHeaderLabel)
            
            let esInfoTextView = UITextView()
            esInfoTextView.font = getFont(0, screenHeight: self.view.frame.height)
            esInfoTextView.textColor = UIColor.wrText()
            esInfoTextView.textAlignment = NSTextAlignment.center
            esInfoTextView.text = "you're now ready to receive payouts"
            esInfoTextView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.574, width: standardWidth, height: self.standardWidth * 3)
            esInfoTextView.isEditable = false
            esInfoTextView.isSelectable = false
            esInfoTextView.isScrollEnabled = false
            esInfoTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
            self.completeView.addSubview(esInfoTextView)
            
            let longButtonHeight = self.view.frame.height * 0.0877
            let longButtonWidth = self.view.frame.width * 0.65
            let esBackButtonView = UIView()
            esBackButtonView.backgroundColor = UIColor.wrGreen()
            esBackButtonView.layer.cornerRadius = longButtonHeight / 2
            esBackButtonView.frame = CGRect(x: (self.view.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.782, width: longButtonWidth, height: longButtonHeight)
            esBackButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
            esBackButtonView.layer.shadowOpacity = 0.7
            esBackButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
            esBackButtonView.layer.shadowRadius = self.view.frame.height * 0.009
            self.completeView.addSubview(esBackButtonView)
            
            let esBackButtonLabel = UILabel()
            esBackButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
            esBackButtonLabel.textColor = UIColor.wrWhite()
            esBackButtonLabel.textAlignment = NSTextAlignment.center
            esBackButtonLabel.text = "done"
            esBackButtonLabel.frame.origin = CGPoint.zero
            esBackButtonLabel.frame.size = esBackButtonView.frame.size
            esBackButtonView.addSubview(esBackButtonLabel)
            
            let esBackButton = UIButton()
            esBackButton.frame.origin = CGPoint.zero
            esBackButton.frame.size = esBackButtonView.frame.size
            esBackButton.addTarget(self, action: #selector(DriverPaymentViewController.closeButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            esBackButtonView.addSubview(esBackButton)
            
            UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                self.masterContentView.frame.origin.x = -self.view.frame.width
                self.completeView.frame.origin.x = 0
            }, completion: { (finished) in
                
            })
            
        case 3:
            print("presenting finished view")
        default:
            break
        }
        
        
        
    }
    
    
    
    func setupAccount() {
        let accountNumber = self.accountNumberTextField.text!
        let institutionNumber = self.institutionNumberTextField.text!
        let transitNumber = self.transitNumberTextField.text!
        
        let routingNumber = "\(transitNumber)-\(institutionNumber)"
        
        let acct = STPBankAccount()
        let acctParams = STPBankAccountParams()
        acctParams.accountHolderName = "Connor Holowachuk"//CurrentUser.fullName
        acctParams.accountHolderType = .individual
        acctParams.currency = "CAD"
        acctParams.country = "CA"
        acctParams.routingNumber = routingNumber
        acctParams.accountNumber = "00\(accountNumber)"
        
        STPAPIClient.shared().createToken(withBankAccount: acctParams, completion: {
            (token, error) in
            
            if error != nil {
                print("error:\n\(error!)")
                self.nextSpinner.stopAnimating()
                self.nextButton.isEnabled = true
                self.nextButtonLabel.isHidden = false
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
                    self.nextSpinner.stopAnimating()
                    self.nextButton.isEnabled = true
                    self.nextButtonLabel.isHidden = false
                    
                    let charArray = Array(acctParams.accountNumber!.characters)
                    let numberOfChars = charArray.count
                    var lastFourDigits = ""
                    for index in 0...3 {
                        let currentIndex = numberOfChars - (4 - index)
                        lastFourDigits = "\(lastFourDigits)\(charArray[currentIndex])"
                    }
                    
                    let dbRef = Database.database().reference().child("users").child("financial").child("09FNiobeKsc6Ovx4Vsgoggo9XDa2").child("lastfourdigits")
                    dbRef.setValue(lastFourDigits)
                    CurrentUser.lastFourDigits = lastFourDigits
                    self.moveToNextView()
                }
                
            }) { (operation, error) -> Void in
                print("failure operation:\n\(operation)")
                print("\nerror:\n\(error)")
                self.nextSpinner.stopAnimating()
                self.nextButton.isEnabled = true
                self.nextButtonLabel.isHidden = false
            }
            
        })
    }
    
    
    func setSINNumber() {
        // set SIN for user's legal_entity
        let stripePostData : [String : Any] = ["stripeid":"acct_1AkvFrD4orhxG8ke", "sin":self.SINTextField.text!]
        
        let stripeSendURL = "http://workride.ca/payment/update-account-sin.php"
        let stripeParams = stripePostData
        
        let stripeAcctManager = AFHTTPSessionManager()
        stripeAcctManager.post(stripeSendURL, parameters: stripeParams, success: { (operation, responseObject) -> Void in
            if let response = responseObject as? [String : Any] {
                print("\nresponse:\n\(response)")
                self.nextSpinner.stopAnimating()
                self.nextButton.isEnabled = true
                self.nextButtonLabel.isHidden = false
                
                let dbRef = Database.database().reference().child("users").child("financial").child("09FNiobeKsc6Ovx4Vsgoggo9XDa2").child("hasUploadedIDNumber")
                dbRef.setValue(true)
                CurrentUser.hasUploadedIDNumber = true
                self.moveToNextView()
                
            }
            
        }) { (operation, error) -> Void in
            print("failure operation:\n\(operation)")
            print("\nerror:\n\(error)")
            self.nextSpinner.stopAnimating()
            self.nextButton.isEnabled = true
            self.nextButtonLabel.isHidden = false
        }
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var allowToEditTF = true
        
        let textString = textField.text
        var charArray = Array(textString!.characters)
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
        
        let numberOfChars = charArray.count
        
        switch textField {
        case self.accountNumberTextField:
            let minRequiredChars = 7
            let maxRequiredChars = 11
            self.accountNumberVerified = false
            if numberOfChars >= minRequiredChars && numberOfChars <= maxRequiredChars {
                self.accountNumberTextField.textColor = UIColor.wrGreen()
                self.accountNumberStatusImageView.image = UIImage(named: "checkmark-small")
                self.accountNumberStatusImageView.isHidden = false
                self.accountNumberAlertLabel.isHidden = true
                self.accountNumberVerified = true
            } else if numberOfChars < maxRequiredChars {
                self.accountNumberTextField.textColor = UIColor.wrText()
                self.accountNumberStatusImageView.isHidden = true
                self.accountNumberAlertLabel.isHidden = true
            } else {
                self.accountNumberTextField.textColor = UIColor.wrText()
                self.accountNumberStatusImageView.image = UIImage(named: "alert-mark")
                self.accountNumberStatusImageView.isHidden = false
                self.accountNumberAlertLabel.isHidden = false
            }
        case self.institutionNumberTextField:
            let requiredChars = 3
            self.institutionNumberVerified = false
            if numberOfChars == requiredChars {
                self.institutionNumberTextField.textColor = UIColor.wrGreen()
                self.institutionNumberStatusImageView.image = UIImage(named: "checkmark-small")
                self.institutionNumberStatusImageView.isHidden = false
                self.institutionNumberAlertLabel.isHidden = true
                self.institutionNumberVerified = true
            } else if numberOfChars < requiredChars {
                self.institutionNumberTextField.textColor = UIColor.wrText()
                self.institutionNumberStatusImageView.isHidden = true
                self.institutionNumberAlertLabel.isHidden = true
            } else {
                self.institutionNumberTextField.textColor = UIColor.wrText()
                self.institutionNumberStatusImageView.image = UIImage(named: "alert-mark")
                self.institutionNumberStatusImageView.isHidden = false
                self.institutionNumberAlertLabel.isHidden = false
            }
        case self.transitNumberTextField:
            let requiredChars = 5
            self.transitNumberVerified = false
            if numberOfChars == requiredChars {
                self.transitNumberTextField.textColor = UIColor.wrGreen()
                self.transitNumberStatusImageView.image = UIImage(named: "checkmark-small")
                self.transitNumberStatusImageView.isHidden = false
                self.transitNumberAlertLabel.isHidden = true
                self.transitNumberVerified = true
            } else if numberOfChars < requiredChars {
                self.transitNumberTextField.textColor = UIColor.wrText()
                self.transitNumberStatusImageView.isHidden = true
                self.transitNumberAlertLabel.isHidden = true
            } else {
                self.transitNumberTextField.textColor = UIColor.wrText()
                self.transitNumberStatusImageView.image = UIImage(named: "alert-mark")
                self.transitNumberStatusImageView.isHidden = false
                self.transitNumberAlertLabel.isHidden = false
            }
        case self.SINTextField:
            let requiredChars = 9
            self.SINVerified = false
            if numberOfChars == requiredChars {
                self.SINTextField.textColor = UIColor.wrGreen()
                self.SINStatusImageView.image = UIImage(named: "checkmark-small")
                self.SINStatusImageView.isHidden = false
                self.SINAlertLabel.isHidden = true
                self.SINVerified = true
            } else if numberOfChars < requiredChars {
                self.SINTextField.textColor = UIColor.wrText()
                self.SINStatusImageView.isHidden = true
                self.SINAlertLabel.isHidden = true
            } else {
                self.SINTextField.textColor = UIColor.wrText()
                self.SINStatusImageView.image = UIImage(named: "alert-mark")
                self.SINStatusImageView.isHidden = false
                self.SINAlertLabel.isHidden = false
            }
        default:
            break
        }
        
        
        if self.accountNumberVerified == true && self.institutionNumberVerified == true && self.transitNumberVerified == true {
            print("okay to check account info")
            self.nextButton.isEnabled = true
            self.nextButtonLabel.textColor = UIColor.wrGreen()
        } else {
            self.nextButton.isEnabled = false
            self.nextButtonLabel.textColor = UIColor.wrLightText()
        }
        
        
        return allowToEditTF
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        return true
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = -self.view.frame.height * 0.3
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0.0
            
        }
    }
}
