//
//  Global.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

protocol GlobalType: class {
  
  var university: PublishSubject<University> { get }
}

final class Global {
  
  static let shared = Global()
  
  private init() { }
  
  var university: PublishSubject<University> = PublishSubject<University>()
}
