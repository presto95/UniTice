//
//  UserDefaultsService.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

protocol UserDefaultsServiceType: class {
  
  var isUpperPostFolded: Bool { get set }
}

final class UserDefaultsService: UserDefaultsServiceType {
  
  static let shared = UserDefaultsService()
  
  var isUpperPostFolded: Bool {
    get {
      return UserDefaults.standard.value(forKey: "fold") as? Bool ?? false
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "fold")
      UserDefaults.standard.synchronize()
    } 
  }
}
