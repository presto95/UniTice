//
//  ObservableType.swift
//  UniTice
//
//  Created by Presto on 24/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

extension ObservableType where Self.E == Bool {
  
  func distinctUntilChangedTrue() -> Observable<Self.E> {
    return distinctUntilChanged().filter { $0 }
  }
}
