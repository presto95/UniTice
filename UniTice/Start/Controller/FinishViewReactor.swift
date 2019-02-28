//
//  FinishViewReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class FinishViewReactor: Reactor {
  
  enum Action {
    
    case touchUpConfirmButton
    
    case touchUpBackButton
  }
  
  enum Mutation {
    
    case setConfirmButtonSelection(Bool)
    
    case setBackButtonSelection(Bool)
  }
  
  struct State {
    
    var isConfirmButtonSelected: Bool = false
    
    var isBackButtonSelected: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .touchUpConfirmButton:
      return Observable.concat([
        Observable.just(Mutation.setConfirmButtonSelection(true)),
        Observable.just(Mutation.setConfirmButtonSelection(false))
        ])
    case .touchUpBackButton:
      return Observable.concat([
        Observable.just(Mutation.setBackButtonSelection(true)),
        Observable.just(Mutation.setBackButtonSelection(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setConfirmButtonSelection(isConfirmButtonSelected):
      state.isConfirmButtonSelected = isConfirmButtonSelected
    case let .setBackButtonSelection(isBackButtonSelected):
      state.isBackButtonSelected = isBackButtonSelected
    }
    return state
  }
}
