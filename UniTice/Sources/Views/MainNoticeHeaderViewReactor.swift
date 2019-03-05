//
//  MainNoticeHeaderViewReactor.swift
//  UniTice
//
//  Created by Presto on 03/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class MainNoticeHeaderViewReactor: Reactor {
  
  enum Action {
    
    case toggleFolding
  }
  
  enum Mutation {
    
    case toggleFolding
  }
  
  struct State {
    
    var isFolding: Bool
  }
  
  let initialState: State
  
  init(isFolding: Bool) {
    initialState = State(isFolding: isFolding)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .toggleFolding:
      return Observable.just(Mutation.toggleFolding)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .toggleFolding:
      state.isFolding.toggle()
    }
    return state
  }
}
