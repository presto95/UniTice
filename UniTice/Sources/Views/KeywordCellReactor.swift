//
//  KeywordCellReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class KeywordCellReactor: Reactor {
  
  typealias Action = NoAction
  
  typealias Mutation = NoMutation
  
  typealias Keyword = String
  
  let initialState: Keyword
  
  init(keyword: Keyword) {
    initialState = keyword
  }
}
