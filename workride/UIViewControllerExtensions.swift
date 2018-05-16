//
//  UIViewControllerExtensions.swift
//  workride
//
//  Created by Connor Holowachuk on 2017-05-29.
//  Copyright © 2017 eigenads. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() -> UITapGestureRecognizer {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        return tap
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
