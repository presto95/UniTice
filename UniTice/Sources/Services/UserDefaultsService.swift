//
//  UserDefaultsService.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

protocol UserDefaultsServiceType: class {
  
  var defaults: UserDefaults { get }
  
  var isUpperPostFolded: Bool { get set }
}

final class UserDefaultsService: UserDefaultsServiceType {
  
  static let shared = UserDefaultsService()
  
  var defaults: UserDefaults {
    return UserDefaults.standard
  }
  
  var isUpperPostFolded: Bool {
    get {
      return defaults.value(forKey: "fold") as? Bool ?? false
    }
    set {
      defaults.set(newValue, forKey: "fold")
      defaults.synchronize()
    } 
  }
}
