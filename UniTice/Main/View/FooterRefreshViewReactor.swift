//
//  FooterRefreshViewReactor.swift
//  UniTice
//
//  Created by Presto on 03/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class FooterRefreshViewReactor: Reactor {
  
  typealias Action = NoAction
    
  struct State {
    
    var isRefreshing: Bool = false
  }
  
  let initialState: State = State()
}

