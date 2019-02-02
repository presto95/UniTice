//
//  UIViewController+.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

extension UIViewController {
  static func instantiate(from storyboard: String, identifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: storyboard, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: identifier)
    return controller
  }
  
  func present(to viewController: UIViewController, transitionStyle style: UIModalTransitionStyle = .coverVertical, animated: Bool = true, completion: (() -> Void)? = nil) {
    modalTransitionStyle = style
    viewController.present(self, animated: animated, completion: completion)
  }
  
  func push(at viewController: UIViewController, animated: Bool = true) {
    viewController.navigationController?.pushViewController(self, animated: animated)
  }
}
