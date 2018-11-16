//
//  UIAlertController+.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func alert(title: String?, message: String?, style: UIAlertController.Style = .alert) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        return alert
    }
    
    @discardableResult
    func action(title: String?, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let action = UIAlertAction(title: title, style: style) { (action) in
            handler?(action)
        }
        self.addAction(action)
        return self
    }
    
    func present(to viewController: UIViewController?, handler: (() -> Void)? = nil) {
        viewController?.present(self, animated: true, completion: handler)
    }
}
