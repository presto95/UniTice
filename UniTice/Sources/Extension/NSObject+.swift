//
//  NSObject+.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

extension NSObject {
  
  var name: String {
    return NSStringFromClass(type(of: self))
  }
  
  static var name: String {
    return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
  }
}
