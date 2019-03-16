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
    
    case loading(Bool)
  }
  
  enum Mutation {
    
    case setLoading(Bool)
  }
    
  struct State {
    
    var isLoading: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .loading(isLoading):
      return Observable.just(Mutation.setLoading(isLoading))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setLoading(isLoading):
      state.isLoading = isLoading
    }
    return state
  }
}
