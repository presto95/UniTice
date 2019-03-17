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

/// The `Reactor` for `FooterLoadingView`.
final class FooterLoadingViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the content table view is in loading.
    case loading(Bool)
  }
  
  enum Mutation {
    
    /// The mutation to set the loading status.
    case setLoading(Bool)
  }
    
  struct State {
    
    /// The boolean value indicating whether the content view is loading.
    var isLoading: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .loading(isLoading):
      return .just(.setLoading(isLoading))
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
