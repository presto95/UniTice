//
//  SafariViewControllerPresentable.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

protocol SafariPresentable: class {
  
  func makeSafariViewController(url: URL) -> UIViewController
}

extension SafariPresentable where Self: UIViewController {
  
  func makeSafariViewController(url: URL) -> UIViewController {
    let config = SFSafariViewController.Configuration().then {
      $0.barCollapsingEnabled = true
      $0.entersReaderIfAvailable = true
    }
    let controller = SFSafariViewController(url: url, configuration: config).then {
      $0.preferredControlTintColor = .main
      $0.dismissButtonStyle = .close
    }
    return controller
  }
}
