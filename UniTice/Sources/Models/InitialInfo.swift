//
//  StartInfo.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

/// 초기 설정을 저장하는 클래스.
final class InitialInfo {
  
  /// InitialInfo Singleton Object.
  static let shared = InitialInfo()
  
  private init() { }
  
  /// 초기 설정한 대학교.
  var university: BehaviorSubject<University> = BehaviorSubject(value: .kaist)
  
  /// 초기 설정한 키워드.
  var keywords: BehaviorSubject<[String]> = BehaviorSubject(value: [])
}
