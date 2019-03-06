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
  
  enum Action {
    
    case refresh
  }
  
  enum Mutation {
    
    case refresh(Bool)
  }
    
  struct State {
    
    var isRefreshing: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      return .concat([
        Observable.just(Mutation.refresh(true)),
        // 사이드 이펙트
        Observable.just(Mutation.refresh(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .refresh(isRefreshing):
      state.isRefreshing = isRefreshing
    }
    return state
  }
}

