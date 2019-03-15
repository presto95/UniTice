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
  
  var university: ReplaySubject<University> { get }
  
  var universityModel: Observable<UniversityType> { get }
}

final class Global: GlobalType {
  
  static let shared = Global()
  
  private init() { }
  
  var university: ReplaySubject<University> = ReplaySubject<University>.create(bufferSize: 1)
  
  var universityModel: Observable<UniversityType> {
    return university.map { $0.model }
  }
}
