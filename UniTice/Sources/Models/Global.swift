//
//  Global.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

enum Global {
  
  static let university: PublishSubject<UniversityModel> = PublishSubject()
}
