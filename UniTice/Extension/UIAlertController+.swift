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
    func textField(_ configuration: ((UITextField) -> Void)? = nil) -> UIAlertController {
        addTextField(configurationHandler: configuration)
        return self
    }
    
    @discardableResult
    func action(title: String?, style: UIAlertAction.Style = .default, handler: ((UIAlertAction, [UITextField]?) -> Void)? = nil) -> UIAlertController {
        guard let textFields = textFields else {
            let action = UIAlertAction(title: title, style: style) { handler?($0, nil) }
            addAction(action)
            return self
        }
        let action = UIAlertAction(title: title, style: style) { handler?($0, textFields) }
        addAction(action)
        return self
    }
    
    func present(to viewController: UIViewController?, animated: Bool = true, handler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            viewController?.present(self, animated: animated, completion: handler)
        }
    }
}

extension UIAlertController {
    static func presentErrorAlert(_ error: Error, to viewController: UIViewController) {
        UIAlertController
            .alert(title: "오류", message: error.localizedDescription)
            .action(title: "확인")
            .present(to: viewController)
    }
}
