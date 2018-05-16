//
//  SignInViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-31.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignInViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    //important constant definitions
    let goldenRatio : CGFloat = 1.61803398875
    let textExtraSpaceFactor : CGFloat = 1.25
    var standardLabelHeight: CGFloat = 0.0
    var smallLabelHeight: CGFloat = 0.0
    var sideMargin: CGFloat = 0.0
    var standardWidth: CGFloat = 0.0
    
    var masterContentView = UIView()
    
    var signInALabel = UILabel()
    var signInBLabel = UILabel()
    var loadingBarView = UIView()
    
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var emailHeaderLabel = UILabel()
    var passwordHeaderLabel = UILabel()
    var passwordCharCounter = 0
    
    var closeButtonView = UIView()
    var closeButtonImageView = UIImageView()
    var closeButton = UIButton()
    
    let signInButtonView = UIView()
    let signInButtonLabel = UILabel()
    let signInButton = UIButton()
    
    let forgotPasswordLabel = UILabel()
    let forgotPasswordButton = UIButton()
    
    
    let resetPasswordView = UIView()
    let rpLoadingBarView = UIView()
    let rpLabelA = UILabel()
    let rpLabelB = UILabel()
    let rpBackButtonView = UIView()
    let rpBackButtonImageView = UIImageView()
    let rpBackButton = UIButton()
    let rpEmailTextFieldHeaderLabel = UILabel()
    let rpEmailTextField = UITextField()
    let rpSendButtonView = UIView()
    let rpSendButtonLabel = UILabel()
    let rpSendButton = UIButton()
    let rpAlertMessageLabel = UILabel()
    let rpAlertImageView = UIImageView()
    var onRPPage = false
    
    
    let emailSentView = UIView()
    let esCheckMarkImageView = UIImageView()
    let esHeaderLabel = UILabel()
    let esInfoTextView = UITextView()
    let esBackButtonView = UIView()
    let esBackButtonLabel = UILabel()
    let esBackButton = UIButton()
    
    
    let errorView = UIView()
    let evAlertImageView = UIImageView()
    let evHeaderLabel = UILabel()
    let evInfoTextView = UITextView()
    let evBackButtonView = UIView()
    let evBackButtonLabel = UILabel()
    let evBackButton = UIButton()
    
    let errorDescriptors: [String:String] = ["The email address is badly formatted.":"looks like you entered an invalid email","The password is invalid or the user does not have a password.":"the password you entered doesn't match the email","There is no user record corresponding to this identifier. The user may have been deleted.":"no account exists for this email"]
    
    var settingUpView = UIView()
    var suHeaderLabel = UILabel()
    var suSpinnerView = UIActivityIndicatorView()
    
    var welcomeView = UIView()
    var wvWelcomeLabel = UILabel()
    var wvNameLabel = UILabel()
    
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
        let longButtonHeight = self.view.frame.height * 0.0877
        let longButtonWidth = self.view.frame.width * 0.65
        
        let roundButtonHeight = self.view.frame.height / 8
        
        
        // set up master content view
        self.masterContentView.frame = self.view.frame
        self.view.addSubview(self.masterContentView)
        
        self.loadingBarView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.1964, width: standardWidth / 5, height: self.view.frame.height * 0.0051)
        self.loadingBarView.backgroundColor = UIColor.wrGreen()
        self.masterContentView.addSubview(self.loadingBarView)
        
        self.signInALabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.signInALabel.textColor = UIColor.wrText()
        self.signInALabel.textAlignment = NSTextAlignment.left
        self.signInALabel.text = "log in and"
        self.signInALabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.217, width: standardWidth, height: standardLabelHeight)
        self.masterContentView.addSubview(self.signInALabel)
        
        self.signInBLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.signInBLabel.textColor = UIColor.wrText()
        self.signInBLabel.textAlignment = NSTextAlignment.left
        self.signInBLabel.text = "get started."
        self.signInBLabel.frame = CGRect(x: sideMargin, y: self.signInALabel.frame.origin.y + self.signInALabel.frame.height, width: standardWidth, height: standardLabelHeight)
        self.masterContentView.addSubview(self.signInBLabel)
        
        self.emailTextField.text = ""
        self.emailTextField.delegate = self
        self.emailTextField.font = getFont(0, screenHeight: self.view.frame.height)
        self.emailTextField.textColor = UIColor.wrText()
        self.emailTextField.autocapitalizationType = .none
        self.emailTextField.autocorrectionType = .no
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.returnKeyType = .next
        self.emailTextField.adjustsFontSizeToFitWidth = true
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "e-mail", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
        self.emailTextField.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.488, width: standardWidth, height: standardLabelHeight)
        self.masterContentView.addSubview(self.emailTextField)
        
        self.passwordTextField.text = ""
        self.passwordTextField.delegate = self
        self.passwordTextField.font = getFont(0, screenHeight: self.view.frame.height)
        self.passwordTextField.textColor = UIColor.wrText()
        self.passwordTextField.autocapitalizationType = .none
        self.passwordTextField.autocorrectionType = .no
        self.passwordTextField.keyboardType = .default
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField.returnKeyType = .go
        self.passwordTextField.adjustsFontSizeToFitWidth = true
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
        self.passwordTextField.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.621, width: standardWidth, height: standardLabelHeight)
        self.masterContentView.addSubview(self.passwordTextField)
        
        self.emailHeaderLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.emailHeaderLabel.textColor = UIColor.wrLightText()
        self.emailHeaderLabel.textAlignment = NSTextAlignment.left
        self.emailHeaderLabel.text = "e-mail"
        self.emailHeaderLabel.frame = CGRect(x: sideMargin, y: self.emailTextField.frame.origin.y - smallLabelHeight, width: standardWidth, height: smallLabelHeight)
        self.masterContentView.addSubview(self.emailHeaderLabel)
        self.emailHeaderLabel.isHidden = true
        
        self.passwordHeaderLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.passwordHeaderLabel.textColor = UIColor.wrLightText()
        self.passwordHeaderLabel.textAlignment = NSTextAlignment.left
        self.passwordHeaderLabel.text = "password"
        self.passwordHeaderLabel.frame = CGRect(x: sideMargin, y: self.passwordTextField.frame.origin.y - smallLabelHeight, width: standardWidth, height: smallLabelHeight)
        self.masterContentView.addSubview(self.passwordHeaderLabel)
        self.passwordHeaderLabel.isHidden = true
        
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
        
        // joinUs button
        self.signInButtonView.backgroundColor = UIColor.wrGreen()
        self.signInButtonView.layer.cornerRadius = longButtonHeight / 2
        self.signInButtonView.frame = CGRect(x: (self.view.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.782, width: longButtonWidth, height: longButtonHeight)
        self.signInButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.signInButtonView.layer.shadowOpacity = 0.7
        self.signInButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.signInButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.masterContentView.addSubview(self.signInButtonView)
        
        self.signInButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.signInButtonLabel.textColor = UIColor.wrWhite()
        self.signInButtonLabel.textAlignment = NSTextAlignment.center
        self.signInButtonLabel.text = "log in"
        self.signInButtonLabel.frame.origin = CGPoint.zero
        self.signInButtonLabel.frame.size = self.signInButtonView.frame.size
        self.signInButtonView.addSubview(self.signInButtonLabel)
        
        self.signInButton.frame.origin = CGPoint.zero
        self.signInButton.frame.size = self.signInButtonView.frame.size
        self.signInButton.addTarget(self, action: #selector(SignInViewController.signInButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.signInButtonView.addSubview(self.signInButton)
        
        self.forgotPasswordLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.forgotPasswordLabel.textColor = UIColor.wrLightText()
        self.forgotPasswordLabel.textAlignment = NSTextAlignment.center
        self.forgotPasswordLabel.text = "i forgot my password"
        self.forgotPasswordLabel.frame = CGRect(x: self.sideMargin, y: self.signInButtonView.frame.origin.y + (self.signInButtonView.frame.height * 1.3), width: self.standardWidth, height: self.standardLabelHeight)
        self.masterContentView.addSubview(self.forgotPasswordLabel)
        
        self.forgotPasswordButton.frame = self.forgotPasswordLabel.frame
        self.forgotPasswordButton.addTarget(self, action: #selector(SignInViewController.forgotPasswordButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.masterContentView.addSubview(self.forgotPasswordButton)
        
        self.masterContentView.isHidden = true
        
        
        // set up reset password view
        self.resetPasswordView.frame = self.view.frame
        self.resetPasswordView.frame.origin.x = self.view.frame.width
        self.view.addSubview(self.resetPasswordView)
        
        self.rpLoadingBarView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.1964, width: standardWidth / 5, height: self.view.frame.height * 0.0051)
        self.rpLoadingBarView.backgroundColor = UIColor.wrGreen()
        self.resetPasswordView.addSubview(self.rpLoadingBarView)
        
        self.rpLabelA.font = getFont(0, screenHeight: self.view.frame.height)
        self.rpLabelA.textColor = UIColor.wrText()
        self.rpLabelA.textAlignment = NSTextAlignment.left
        self.rpLabelA.text = "enter your email to"
        self.rpLabelA.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.217, width: standardWidth, height: standardLabelHeight)
        self.resetPasswordView.addSubview(self.rpLabelA)
        
        self.rpLabelB.font = getFont(1, screenHeight: self.view.frame.height)
        self.rpLabelB.textColor = UIColor.wrText()
        self.rpLabelB.textAlignment = NSTextAlignment.left
        self.rpLabelB.text = "reset your password."
        self.rpLabelB.frame = CGRect(x: sideMargin, y: self.signInALabel.frame.origin.y + self.signInALabel.frame.height, width: standardWidth, height: standardLabelHeight)
        self.resetPasswordView.addSubview(self.rpLabelB)
        
        self.rpEmailTextField.text = ""
        self.rpEmailTextField.delegate = self
        self.rpEmailTextField.font = getFont(0, screenHeight: self.view.frame.height)
        self.rpEmailTextField.textColor = UIColor.wrText()
        self.rpEmailTextField.autocapitalizationType = .none
        self.rpEmailTextField.autocorrectionType = .no
        self.rpEmailTextField.keyboardType = .emailAddress
        self.rpEmailTextField.returnKeyType = .send
        self.rpEmailTextField.adjustsFontSizeToFitWidth = true
        self.rpEmailTextField.attributedPlaceholder = NSAttributedString(string: "e-mail", attributes: [NSForegroundColorAttributeName: UIColor.wrLightText(), NSFontAttributeName: getFont(0, screenHeight: self.view.frame.height)])
        self.rpEmailTextField.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.488, width: standardWidth, height: standardLabelHeight)
        self.resetPasswordView.addSubview(self.rpEmailTextField)
        
        self.rpEmailTextFieldHeaderLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.rpEmailTextFieldHeaderLabel.textColor = UIColor.wrLightText()
        self.rpEmailTextFieldHeaderLabel.textAlignment = NSTextAlignment.left
        self.rpEmailTextFieldHeaderLabel.text = "e-mail"
        self.rpEmailTextFieldHeaderLabel.frame = CGRect(x: sideMargin, y: self.rpEmailTextField.frame.origin.y - smallLabelHeight, width: standardWidth, height: smallLabelHeight)
        self.resetPasswordView.addSubview(self.rpEmailTextFieldHeaderLabel)
        self.rpEmailTextFieldHeaderLabel.isHidden = true
        
        self.rpSendButtonView.backgroundColor = UIColor.wrGreen()
        self.rpSendButtonView.layer.cornerRadius = longButtonHeight / 2
        self.rpSendButtonView.frame = CGRect(x: (self.view.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.782, width: longButtonWidth, height: longButtonHeight)
        self.rpSendButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.rpSendButtonView.layer.shadowOpacity = 0.7
        self.rpSendButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.rpSendButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.resetPasswordView.addSubview(self.rpSendButtonView)
        
        self.rpSendButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.rpSendButtonLabel.textColor = UIColor.wrWhite()
        self.rpSendButtonLabel.textAlignment = NSTextAlignment.center
        self.rpSendButtonLabel.text = "send email"
        self.rpSendButtonLabel.frame.origin = CGPoint.zero
        self.rpSendButtonLabel.frame.size = self.rpSendButtonView.frame.size
        self.rpSendButtonView.addSubview(self.rpSendButtonLabel)
        
        self.rpSendButton.frame.origin = CGPoint.zero
        self.rpSendButton.frame.size = self.signInButtonView.frame.size
        self.rpSendButton.addTarget(self, action: #selector(SignInViewController.sendResetPasswordEmailButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.rpSendButtonView.addSubview(self.rpSendButton)
        
        self.rpBackButtonView.frame = CGRect(x: self.sideMargin * 0.8, y: self.view.frame.height * 0.0915, width: closeButtonHeight, height: closeButtonHeight)
        self.resetPasswordView.addSubview(self.rpBackButtonView)
        
        self.rpBackButtonImageView.frame.origin = CGPoint.zero
        self.rpBackButtonImageView.frame.size = self.rpBackButtonView.frame.size
        self.rpBackButtonImageView.image = UIImage(named: "back")
        self.rpBackButtonView.addSubview(self.rpBackButtonImageView)
        
        self.rpBackButton.frame.origin = CGPoint.zero
        self.rpBackButton.frame.size = self.closeButtonView.frame.size
        self.rpBackButton.addTarget(self, action: #selector(SignInViewController.rpBackButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.rpBackButtonView.addSubview(self.rpBackButton)
        
        self.rpAlertMessageLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.rpAlertMessageLabel.textColor = UIColor.wrAlert()
        self.rpAlertMessageLabel.textAlignment = NSTextAlignment.left
        self.rpAlertMessageLabel.text = "please enter a valid email address"
        self.rpAlertMessageLabel.frame = CGRect(x: sideMargin, y: self.rpEmailTextField.frame.origin.y + self.rpEmailTextField.frame.height, width: standardWidth, height: standardLabelHeight)
        self.resetPasswordView.addSubview(self.rpAlertMessageLabel)
        self.rpAlertMessageLabel.isHidden = true
        
        let alertMarkImageViewHeight = self.view.frame.height * 0.03
        self.rpAlertImageView.frame = CGRect(x: self.emailTextField.frame.origin.x + self.rpEmailTextField.frame.width, y: self.rpEmailTextField.frame.origin.y + ((self.rpEmailTextField.frame.height - alertMarkImageViewHeight) / 2), width: alertMarkImageViewHeight, height: alertMarkImageViewHeight)
        self.rpAlertImageView.image = UIImage(named: "alert-mark")
        self.rpAlertImageView.isHidden = true
        self.resetPasswordView.addSubview(self.rpAlertImageView)
        
        
        
        // email sent view
        self.emailSentView.frame = self.view.frame
        
        let esCheckMarkImageHeight = self.view.frame.height * 0.255
        self.esCheckMarkImageView.frame = CGRect(x: (self.view.frame.width - esCheckMarkImageHeight) / 2, y: self.view.frame.height * 0.198, width: esCheckMarkImageHeight, height: esCheckMarkImageHeight)
        self.esCheckMarkImageView.image = UIImage(named: "checkmark-large")
        self.emailSentView.addSubview(self.esCheckMarkImageView)
        
        self.esHeaderLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.esHeaderLabel.textColor = UIColor.wrText()
        self.esHeaderLabel.textAlignment = NSTextAlignment.center
        self.esHeaderLabel.text = "email sent!"
        self.esHeaderLabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.471, width: standardWidth, height: standardLabelHeight)
        self.emailSentView.addSubview(self.esHeaderLabel)
        
        self.esInfoTextView.font = getFont(0, screenHeight: self.view.frame.height)
        self.esInfoTextView.textColor = UIColor.wrText()
        self.esInfoTextView.textAlignment = NSTextAlignment.center
        self.esInfoTextView.text = "check your inbox for your reset password email"
        self.esInfoTextView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.574, width: standardWidth, height: self.standardWidth * 3)
        self.esInfoTextView.isEditable = false
        self.esInfoTextView.isSelectable = false
        self.esInfoTextView.isScrollEnabled = false
        self.esInfoTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        self.emailSentView.addSubview(self.esInfoTextView)
        
        self.esBackButtonView.backgroundColor = UIColor.wrGreen()
        self.esBackButtonView.layer.cornerRadius = longButtonHeight / 2
        self.esBackButtonView.frame = CGRect(x: (self.view.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.782, width: longButtonWidth, height: longButtonHeight)
        self.esBackButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.esBackButtonView.layer.shadowOpacity = 0.7
        self.esBackButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.esBackButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.emailSentView.addSubview(self.esBackButtonView)
        
        self.esBackButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.esBackButtonLabel.textColor = UIColor.wrWhite()
        self.esBackButtonLabel.textAlignment = NSTextAlignment.center
        self.esBackButtonLabel.text = "back"
        self.esBackButtonLabel.frame.origin = CGPoint.zero
        self.esBackButtonLabel.frame.size = self.esBackButtonView.frame.size
        self.esBackButtonView.addSubview(self.esBackButtonLabel)
        
        self.esBackButton.frame.origin = CGPoint.zero
        self.esBackButton.frame.size = self.esBackButtonView.frame.size
        self.esBackButton.addTarget(self, action: #selector(SignInViewController.returnToLoginButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.esBackButtonView.addSubview(self.esBackButton)
        
        
        // email sent view
        self.errorView.frame = self.view.frame
        
        self.evAlertImageView.frame = CGRect(x: (self.view.frame.width - esCheckMarkImageHeight) / 2, y: self.view.frame.height * 0.198, width: esCheckMarkImageHeight, height: esCheckMarkImageHeight)
        self.evAlertImageView.image = UIImage(named: "alert-mark-large")
        self.errorView.addSubview(self.evAlertImageView)
        
        self.evHeaderLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.evHeaderLabel.textColor = UIColor.wrText()
        self.evHeaderLabel.textAlignment = NSTextAlignment.center
        self.evHeaderLabel.text = "uh-oh!"
        self.evHeaderLabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.471, width: standardWidth, height: standardLabelHeight)
        self.errorView.addSubview(self.evHeaderLabel)
        
        self.evInfoTextView.font = getFont(0, screenHeight: self.view.frame.height)
        self.evInfoTextView.textColor = UIColor.wrText()
        self.evInfoTextView.textAlignment = NSTextAlignment.center
        self.evInfoTextView.text = "looks like you entered an invalid email"
        self.evInfoTextView.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.574, width: standardWidth, height: self.standardWidth * 3)
        self.evInfoTextView.isEditable = false
        self.evInfoTextView.isSelectable = false
        self.evInfoTextView.isScrollEnabled = false
        self.evInfoTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        self.errorView.addSubview(self.evInfoTextView)
        
        self.evBackButtonView.backgroundColor = UIColor.wrGreen()
        self.evBackButtonView.layer.cornerRadius = longButtonHeight / 2
        self.evBackButtonView.frame = CGRect(x: (self.view.frame.width - longButtonWidth) / 2, y: self.view.frame.height * 0.782, width: longButtonWidth, height: longButtonHeight)
        self.evBackButtonView.layer.shadowColor = UIColor.wrGreenShadow().cgColor
        self.evBackButtonView.layer.shadowOpacity = 0.7
        self.evBackButtonView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.009)
        self.evBackButtonView.layer.shadowRadius = self.view.frame.height * 0.009
        self.errorView.addSubview(self.evBackButtonView)
        
        self.evBackButtonLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.evBackButtonLabel.textColor = UIColor.wrWhite()
        self.evBackButtonLabel.textAlignment = NSTextAlignment.center
        self.evBackButtonLabel.text = "back"
        self.evBackButtonLabel.frame.origin = CGPoint.zero
        self.evBackButtonLabel.frame.size = self.evBackButtonView.frame.size
        self.evBackButtonView.addSubview(self.evBackButtonLabel)
        
        self.evBackButton.frame.origin = CGPoint.zero
        self.evBackButton.frame.size = self.evBackButtonView.frame.size
        self.evBackButton.addTarget(self, action: #selector(SignInViewController.evBackButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.evBackButtonView.addSubview(self.evBackButton)
        
        
        // setting up account view
        self.settingUpView.frame = self.view.frame
        
        self.suHeaderLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.suHeaderLabel.textColor = UIColor.wrText()
        self.suHeaderLabel.textAlignment = NSTextAlignment.center
        self.suHeaderLabel.text = "signing in..."
        self.suHeaderLabel.frame = CGRect(x: 0, y: self.view.frame.height * 0.576, width: self.view.frame.width, height: self.standardLabelHeight)
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
        self.wvWelcomeLabel.frame = CGRect(x: 0, y: (self.view.frame.height / 2) - self.standardLabelHeight, width: self.view.frame.width, height: self.standardLabelHeight)
        self.welcomeView.addSubview(self.wvWelcomeLabel)
        
        self.wvNameLabel.font = getFont(0, screenHeight: self.view.frame.height)
        self.wvNameLabel.textColor = UIColor.wrText()
        self.wvNameLabel.textAlignment = NSTextAlignment.center
        self.wvNameLabel.text = "friend"
        self.wvNameLabel.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: self.standardLabelHeight)
        self.welcomeView.addSubview(self.wvNameLabel)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.masterContentView.isHidden = false
        self.masterContentView.frame.origin.x = self.view.frame.width
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseOut, animations: {
            self.masterContentView.frame.origin.x = 0
        }, completion: { (finished) in
            
        })
    }
    
    func closeButtonPressed(_ sender: UIButton) {
        print("close button pressed")
        
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseIn, animations: {
            self.masterContentView.frame.origin.x = self.view.frame.width
        }, completion: { (finished) in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    func signInButtonPressed(_ sender: UIButton) {
        print("join us button pressed")
        
        let enteredEmail = self.emailTextField.text!
        let emailCharArray = Array(enteredEmail.characters)
        
        if self.emailTextField.isEditing { self.emailTextField.resignFirstResponder() }
        if self.passwordTextField.isEditing { self.passwordTextField.resignFirstResponder() }
        
        var emailIsValidated = false
        if emailCharArray.count > 0 {
            var containsAt = false
            var containsDot = false
            for index in 0...emailCharArray.count - 1 {
                let currentCharASCII = emailCharArray[index].unicodeScalarCodePoint()
                if currentCharASCII == 64 {containsAt = true}
                if containsAt == true {
                    if currentCharASCII == 46 {containsDot = true}
                }
            }
            if containsAt == true && containsDot == true {emailIsValidated = true}
        }
        
        if emailIsValidated {
            let enteredPassword = self.passwordTextField.text!
            let passwordCharArray = Array(enteredPassword.characters)
            if passwordCharArray.count > 5 {
                
                self.view.addSubview(self.settingUpView)
                self.settingUpView.frame.origin.x = self.view.frame.width
                self.suSpinnerView.startAnimating()
                UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.masterContentView.frame.origin.x = -self.view.frame.width
                    self.settingUpView.frame.origin.x = 0
                }, completion: { (finished) in
                    
                    self.attemptSignIn()
                })
            } else {
                self.evInfoTextView.text = "looks like you entered an invalid password"
                self.showErrorLoggingInView()
            }
        } else {
            self.evInfoTextView.text = "looks like you entered an invalid email"
            self.showErrorLoggingInView()
        }
        
        
    }
    
    func forgotPasswordButtonPressed(_ sender: UIButton) {
        print("forgot password button pressed")
        self.onRPPage = true
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.masterContentView.frame.origin.x = -self.view.frame.width
            self.resetPasswordView.frame.origin.x = 0
        }, completion: { (finished) in
            
        })
    }
    
    func sendResetPasswordEmailButtonPressed(_ sender: UIButton) {
        print("sendResetPasswordEmailButtonPressed")
        self.sendResetPasswordEmail()
    }
    
    
    func rpBackButtonPressed(_ sender: UIButton) {
        print("rpBackButtonPressed")
        self.onRPPage = false
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.masterContentView.frame.origin.x = 0
            self.resetPasswordView.frame.origin.x = self.view.frame.width
        }, completion: { (finished) in
            
        })
    }
    
    func evBackButtonPressed(_ sender: UIButton) {
        print("evBackButtonPressed")
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.masterContentView.frame.origin.x = 0
            self.errorView.frame.origin.x = self.view.frame.width
        }, completion: { (finished) in
            self.errorView.removeFromSuperview()
        })
    }
    
    func showErrorLoggingInView() {
        self.view.addSubview(self.errorView)
        self.errorView.frame.origin.x = self.view.frame.width
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.masterContentView.frame.origin.x = -self.view.frame.width
            self.settingUpView.frame.origin.x = -self.view.frame.width
            self.errorView.frame.origin.x = 0
        }, completion: { (finished) in
            self.settingUpView.removeFromSuperview()
        })
    }
    
    func attemptSignIn() {
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {
            user, error in
            

            if error != nil {
                self.suSpinnerView.stopAnimating()
                self.evInfoTextView.text = self.errorDescriptors[(error?.localizedDescription)!]
                self.showErrorLoggingInView()
                print(error?.localizedDescription as Any)
            } else {
                //sign in initiated
                
                print("Sign in successful - from login.\n")
                print(user?.uid as Any)
                
                let userinfoRef = Database.database().reference().child("users").child("userinfo").child((user?.uid)!)
                userinfoRef.observeSingleEvent(of: .value, with: {  (snapshot) in
                    
                    if snapshot.exists() {
                        let userinfoData = snapshot.value as? NSDictionary
                        let quickInfoData = userinfoData?["quick"] as? NSDictionary
                        
                        CurrentUser.firstName = (quickInfoData?["firstname"] as? String)!
                        CurrentUser.lastName = (quickInfoData?["lastname"] as? String)!
                        CurrentUser.fullName = (userinfoData?["fullname"] as? String)!
                        
                        CurrentUser.firebaseUID = (user?.uid)!
                        
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
                            print("getting financial info")
                            if finSnapshot.hasChild("stripeaccountid") {
                                let finInfoData = finSnapshot.value as? NSDictionary
                                CurrentUser.stripeAccountID = (finInfoData?["stripeaccountid"] as? String)!
                                print("user stripe id: \(finInfoData)")
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
                                    toDayRef.observeSingleEvent(of: .value, with: {  (toSnapshot) in
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
                                    fromDayRef.observeSingleEvent(of: .value, with: {  (fromSnapshot) in
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
                                self.suSpinnerView.stopAnimating()
                                self.moveToApp(isDriver: CurrentUser.signedUpAsDriver)
                            }
                        })
                        
                        let profilePhotoURL = user?.photoURL
                        
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
            }
        }
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
    
    func validateResetPasswordEmail() -> Bool {
        let enteredEmail = self.rpEmailTextField.text
        let charArray = Array(enteredEmail!.characters)
        var isValidated = false
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
        
        if isValidated {
            self.rpAlertImageView.isHidden = true
            self.rpAlertMessageLabel.isHidden = true
        } else {
            self.rpAlertImageView.isHidden = false
            self.rpAlertMessageLabel.isHidden = false
        }
        
        return isValidated
    }
    
    func sendResetPasswordEmail() {
        if self.validateResetPasswordEmail() {
            UIView.animate(withDuration: 0.12, delay: 0.0, options: .curveEaseInOut, animations: {
                self.resetPasswordView.alpha = 0.0
            }, completion: { (finished) in
                self.resetPasswordView.frame.origin.x = self.view.frame.width
                self.resetPasswordView.alpha = 1.0
                self.view.addSubview(self.emailSentView)
                self.emailSentView.alpha = 0.0
                UIView.animate(withDuration: 0.12, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.emailSentView.alpha = 1.0
                }, completion: { (finished) in
                    
                })
            })
        }
    }
    
    func returnToLoginButtonPressed(_ sender: UIButton) {
        print("returnToLoginButtonPressed")
        
        self.masterContentView.frame.origin.x = -self.view.frame.width
        UIView.animate(withDuration: 0.369, delay: 0.0, options: .curveEaseInOut, animations: {
            self.masterContentView.frame.origin.x = 0
            self.emailSentView.frame.origin.x = self.view.frame.width
        }, completion: { (finished) in
            self.emailSentView.removeFromSuperview()
            self.rpEmailTextField.text = ""
        })
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var allowToEditTF = true
        
        if textField == self.emailTextField {
            let textString = self.emailTextField.text
            var numberOfCharsInEmailTF = Array(textString!.characters).count
            
            if string == "" {numberOfCharsInEmailTF -= 1} else {numberOfCharsInEmailTF += 1}
            
            if numberOfCharsInEmailTF == 0 {
                self.emailHeaderLabel.isHidden = true
            } else {
                self.emailHeaderLabel.isHidden = false
            }
            
        } else if textField == self.passwordTextField {
            if string == " " {
                allowToEditTF = false
            } else if string == "" {
                if self.passwordCharCounter != 0 {self.passwordCharCounter -= 1}
            } else {
                self.passwordCharCounter += 1
            }
            print("edit password: \(string), \(self.passwordCharCounter)")
            if self.passwordCharCounter == 0 {
                self.passwordHeaderLabel.isHidden = true
            } else {
                self.passwordHeaderLabel.isHidden = false
            }
        } else if textField == self.rpEmailTextField {
            self.rpAlertMessageLabel.isHidden = true
            self.rpAlertImageView.isHidden = true
            let textString = self.rpEmailTextField.text
            var numberOfCharsInEmailTF = Array(textString!.characters).count
            
            if string == "" {numberOfCharsInEmailTF -= 1} else {numberOfCharsInEmailTF += 1}
            
            if numberOfCharsInEmailTF == 0 {
                self.rpEmailTextFieldHeaderLabel.isHidden = true
            } else {
                self.rpEmailTextFieldHeaderLabel.isHidden = false
            }
        }
        
        return allowToEditTF
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.signInButtonPressed(self.signInButton)
            self.passwordCharCounter = 0
            textField.resignFirstResponder()
        } else if textField == self.rpEmailTextField {
            textField.resignFirstResponder()
            if self.validateResetPasswordEmail() {
                self.sendResetPasswordEmail()
            }
        }
        
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
            self.passwordCharCounter = 0
            if self.onRPPage {
                self.validateResetPasswordEmail()
            }
        }
    }
    
}
