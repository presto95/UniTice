//
//  UIView+.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

extension UIView {

  static func instantiate<T>(fromXib name: String) -> T? where T: UIView {
    return UINib(nibName: name, bundle: nil)
      .instantiate(withOwner: nil, options: nil).first as? T
  }
}
