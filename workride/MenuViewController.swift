//
//  MenuViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-03.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class MenuViewController: UIViewController {
    
    //important constant definitions
    let goldenRatio : CGFloat = 1.61803398875
    let textExtraSpaceFactor : CGFloat = 1.25
    var standardLabelHeight: CGFloat = 0.0
    var smallLabelHeight: CGFloat = 0.0
    var sideMargin: CGFloat = 0.0
    var smallSideMargin: CGFloat = 0.0
    var standardWidth: CGFloat = 0.0
    let headerView = UIView()
    
    let backCardView = UIView()
    let profileImageView = UIImageView()
    let profileNameLabel = UILabel()
    let profileEmailLabel = UILabel()
    
    let menuLabelNames = ["drive times", "schedule", "messages", "profile"]
    var menuLabels: [UILabel] = []
    var menuButtons: [UIButton] = []
    let segueNames = ["DriveTimeSegue", "ScheduleSegue", "MessagesSegue", "ProfileSegue"]
    let menuSelectView = UIView()
    
    let logOutButtonLabel = UILabel()
    let logOutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.wrOffWhite()
        
        
        //important constant definitions
        self.standardLabelHeight = self.view.frame.height * 0.03973013493 * self.textExtraSpaceFactor
        self.smallLabelHeight = standardLabelHeight / self.goldenRatio * self.textExtraSpaceFactor
        self.sideMargin = self.view.frame.width * 0.113
        self.smallSideMargin = self.view.frame.width * 0.048
        self.standardWidth = self.view.frame.width - (2 * sideMargin)
        
        
        // header view
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.23)
        self.headerView.backgroundColor = UIColor.wrGreen()
        self.view.addSubview(self.headerView)
        
        // back card view
        self.backCardView.frame = CGRect(x: -self.sideMargin, y: self.view.frame.height * 0.085, width: self.view.frame.width - (self.sideMargin), height: self.view.frame.height * 0.864)
        self.backCardView.layer.cornerRadius = self.view.frame.width * 0.036
        self.backCardView.layer.shadowColor = UIColor.black.cgColor
        self.backCardView.layer.shadowRadius = self.view.frame.width * 0.024
        self.backCardView.layer.shadowOpacity = 0.2
        self.backCardView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.backCardView.backgroundColor = UIColor.wrWhite()
        self.view.addSubview(self.backCardView)
        
        let cardContentSideMargin = 2 * self.sideMargin
        // profile content
        let profileImageViewWidth = self.view.frame.width * 0.267
        self.profileImageView.frame = CGRect(x: cardContentSideMargin, y: self.view.frame.height * 0.072, width: profileImageViewWidth, height: profileImageViewWidth)
        self.profileImageView.image = CurrentUser.profileImage
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = profileImageViewWidth / 2
        self.profileImageView.clipsToBounds = true
        self.backCardView.addSubview(self.profileImageView)
        
        self.profileNameLabel.font = getFont(1, screenHeight: self.view.frame.height)
        self.profileNameLabel.textColor = UIColor.wrText()
        self.profileNameLabel.textAlignment = NSTextAlignment.left
        self.profileNameLabel.text = CurrentUser.firstName
        self.profileNameLabel.frame = CGRect(x: cardContentSideMargin, y: self.view.frame.height * 0.247, width: self.backCardView.frame.width - cardContentSideMargin - self.smallSideMargin, height: standardLabelHeight)
        self.backCardView.addSubview(self.profileNameLabel)
        
        self.profileEmailLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.profileEmailLabel.textColor = UIColor.wrLightText()
        self.profileEmailLabel.textAlignment = NSTextAlignment.left
        self.profileEmailLabel.text = CurrentUser.email
        self.profileEmailLabel.frame = CGRect(x: cardContentSideMargin, y: self.profileNameLabel.frame.origin.y + self.profileNameLabel.frame.height, width: self.backCardView.frame.width - cardContentSideMargin - self.smallSideMargin, height: self.smallLabelHeight)
        self.backCardView.addSubview(self.profileEmailLabel)
        
        let menuButtonStartingYPosition = self.view.frame.height * 0.395
        let menuButtonTotalHeight = self.view.frame.height * 0.371
        let menuButtonHeight = self.view.frame.height * 0.0705
        let menuButtonSpacing = (menuButtonTotalHeight - (CGFloat(self.menuLabelNames.count) * menuButtonHeight)) / CGFloat(self.menuLabelNames.count - 1)
        for index in 0..<self.menuLabelNames.count {
            
            let newRect = CGRect(x: cardContentSideMargin, y: menuButtonStartingYPosition + (CGFloat(index) * (menuButtonHeight + menuButtonSpacing)), width: self.profileNameLabel.frame.width, height: menuButtonHeight)
            
            let newLabel = UILabel()
            newLabel.font = getFont(0, screenHeight: self.view.frame.height)
            if index != 0 {newLabel.textColor = UIColor.wrText()} else {newLabel.textColor = UIColor.wrGreen()}
            newLabel.textAlignment = NSTextAlignment.left
            newLabel.text = self.menuLabelNames[index]
            newLabel.frame = newRect
            self.backCardView.addSubview(newLabel)
            self.menuLabels.append(newLabel)
            
            let newButton = UIButton()
            newButton.addTarget(self, action: #selector(MenuViewController.menuButtonPressed(_:)), for: .touchUpInside)
            newButton.frame = newRect
            self.backCardView.addSubview(newButton)
            self.menuButtons.append(newButton)
            
        }
        
        let menuSelectViewWidth = self.view.frame.width * 0.0213
        self.menuSelectView.frame = CGRect(x: self.backCardView.frame.width - menuSelectViewWidth, y: self.menuLabels[0].frame.origin.y, width: menuSelectViewWidth, height: self.menuLabels[0].frame.height)
        self.menuSelectView.backgroundColor = UIColor.wrGreen()
        self.backCardView.addSubview(self.menuSelectView)
        
        self.logOutButtonLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.logOutButtonLabel.textColor = UIColor.wrLightText()
        self.logOutButtonLabel.textAlignment = NSTextAlignment.left
        self.logOutButtonLabel.text = "log out"
        self.logOutButtonLabel.frame = CGRect(x: cardContentSideMargin, y: self.backCardView.frame.height - (2 * self.smallLabelHeight), width: self.backCardView.frame.width - cardContentSideMargin - self.smallSideMargin, height: self.smallLabelHeight)
        self.backCardView.addSubview(self.logOutButtonLabel)
        
        self.logOutButton.frame = self.logOutButtonLabel.frame
        self.logOutButton.addTarget(self, action: #selector(MenuViewController.logOutButtonPressed(_:)), for: .touchUpInside)
        self.backCardView.addSubview(self.logOutButton)
    }
    
    
    func menuButtonPressed(_ sender: UIButton) {
        self.profileImageView.image = CurrentUser.profileImage
        
        var selectedIndex = 0
        for index in 0..<self.menuButtons.count {
            if self.menuButtons[index] == sender {selectedIndex = index}
            self.menuLabels[index].textColor = UIColor.wrText()
        }
        
        print("\(self.menuLabelNames[selectedIndex]) button pressed")
        self.menuLabels[selectedIndex].textColor = UIColor.wrGreen()
        self.menuSelectView.frame.origin.y = self.menuLabels[selectedIndex].frame.origin.y
        self.performSegue(withIdentifier: self.segueNames[selectedIndex], sender: nil)
    }
    
    func logOutButtonPressed(_ sender: UIButton) {
        print("log out button pressed")
        try! Auth.auth().signOut()
        resetCurrentUser()
        
        
        self.performSegue(withIdentifier: "LogOutSegue", sender: nil)
    }
    
    //hide statusBar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //animate status bar back on screen
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
}
