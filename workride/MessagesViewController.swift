//
//  MessagesViewController.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-06-05.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit

class MessagesViewController: UIViewController {
    
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
    
    let numberOfNewMessagesLabel = UILabel()
    let noNewMessagesView = UIView()
    let recentConversationsLabel = UILabel()
    
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
        self.headerLabel.text = "messages"
        self.headerLabel.frame = CGRect(x: sideMargin, y: self.view.frame.height * 0.072, width: standardWidth, height: standardLabelHeight)
        self.headerView.addSubview(self.headerLabel)
        
        let menuImageWidth = self.view.frame.width * 0.104
        self.menuImageView.image = UIImage(named: "menu-burger")
        self.menuImageView.frame = CGRect(x: self.smallSideMargin, y: self.headerLabel.frame.origin.y - ((menuImageWidth - self.standardLabelHeight) / 2), width: menuImageWidth, height: menuImageWidth)
        self.headerView.addSubview(self.menuImageView)
        
        self.menuButton.frame = self.menuImageView.frame
        self.menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
        self.headerView.addSubview(self.menuButton)
        
        self.numberOfNewMessagesLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.numberOfNewMessagesLabel.textColor = UIColor.wrWhite()
        self.numberOfNewMessagesLabel.textAlignment = NSTextAlignment.left
        self.numberOfNewMessagesLabel.text = "no new messages"
        self.numberOfNewMessagesLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.144, width: self.standardWidth, height: self.standardLabelHeight)
        self.headerView.addSubview(self.numberOfNewMessagesLabel)
        
        
        // no new messages view
        self.noNewMessagesView.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.19, width: self.standardWidth, height: self.view.frame.height * 0.215)
        self.noNewMessagesView.layer.cornerRadius = self.view.frame.width * 0.036
        self.noNewMessagesView.layer.shadowColor = UIColor.black.cgColor
        self.noNewMessagesView.layer.shadowRadius = self.view.frame.width * 0.024
        self.noNewMessagesView.layer.shadowOpacity = 0.2
        self.noNewMessagesView.layer.shadowOffset = CGSize(width: 0, height: self.view.frame.height * 0.0015)
        self.noNewMessagesView.backgroundColor = UIColor.wrWhite()
        self.view.addSubview(self.noNewMessagesView)
        
        let noNewMessagesCheckmarkImageView = UIImageView()
        let checkmarkImageHeight = self.view.frame.height * 0.115
        noNewMessagesCheckmarkImageView.image = UIImage(named: "checkmark-large")
        noNewMessagesCheckmarkImageView.frame = CGRect(x: (self.noNewMessagesView.frame.width - checkmarkImageHeight) / 2, y: self.view.frame.height * 0.03, width: checkmarkImageHeight, height: checkmarkImageHeight)
        self.noNewMessagesView.addSubview(noNewMessagesCheckmarkImageView)
        
        let noNewMessagesLabel = UILabel()
        noNewMessagesLabel.font = getFont(2, screenHeight: self.view.frame.height)
        noNewMessagesLabel.textColor = UIColor.wrText()
        noNewMessagesLabel.textAlignment = NSTextAlignment.center
        noNewMessagesLabel.text = "all caught up!"
        noNewMessagesLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.151, width: self.noNewMessagesView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.noNewMessagesView.addSubview(noNewMessagesLabel)
        
        
        // recent conversations label
        self.recentConversationsLabel.font = getFont(2, screenHeight: self.view.frame.height)
        self.recentConversationsLabel.textColor = UIColor.wrLightText()
        self.recentConversationsLabel.textAlignment = NSTextAlignment.left
        self.recentConversationsLabel.text = "recent conversations"
        self.recentConversationsLabel.frame = CGRect(x: self.smallSideMargin, y: self.view.frame.height * 0.447, width: self.noNewMessagesView.frame.width - (2 * self.smallSideMargin), height: self.standardLabelHeight)
        self.view.addSubview(self.recentConversationsLabel)
        
        let comingSoonHeaderLabel = UILabel()
        comingSoonHeaderLabel.font = getFont(0, screenHeight: self.view.frame.height)
        comingSoonHeaderLabel.textColor = UIColor.wrLightText()
        comingSoonHeaderLabel.textAlignment = .center
        comingSoonHeaderLabel.text = "coming soon"
        comingSoonHeaderLabel.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.624, width: self.standardWidth, height: self.standardLabelHeight)
        self.view.addSubview(comingSoonHeaderLabel)
        
        let comingSoonDescriptorTextView = UITextView()
        comingSoonDescriptorTextView.font = getFont(2, screenHeight: self.view.frame.height)
        comingSoonDescriptorTextView.textColor = UIColor.wrLightText()
        comingSoonDescriptorTextView.backgroundColor = UIColor.clear
        comingSoonDescriptorTextView.textAlignment = .center
        comingSoonDescriptorTextView.isEditable = false
        comingSoonDescriptorTextView.isSelectable = false
        comingSoonDescriptorTextView.isScrollEnabled = false
        //comingSoonDescriptorTextView.contentInset = UIEdgeInsetsMake(-4, -6, 0, 0)
        comingSoonDescriptorTextView.text = "the conversations feature will be avaliable in coming updates"
        comingSoonDescriptorTextView.frame = CGRect(x: self.sideMargin, y: self.view.frame.height * 0.69, width: self.standardWidth, height: self.standardLabelHeight * 3)
        self.view.addSubview(comingSoonDescriptorTextView)
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
