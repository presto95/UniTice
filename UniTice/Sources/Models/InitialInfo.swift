//
//  StartInfo.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation
import RxSwift

final class InitialInfo {
  
  static let shared = InitialInfo()
  
  private init() { }
  
  var university: BehaviorSubject<University> = BehaviorSubject(value: .kaist)
  
  var keywords: BehaviorSubject<[String]> = BehaviorSubject(value: [])
}
