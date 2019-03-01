//
//  KeywordRegisterReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class KeywordRegisterViewReactor: Reactor {
  
  enum Action {
    
    case touchUpConfirmButton
    
    case touchUpBackButton
    
    case addKeyword(String?)
    
    case removeKeyword(index: Int)
  }
  
  enum Mutation {
    
    case setConfirmButtonSelection(Bool)
    
    case setBackButtonSelection(Bool)
    
    case addKeyword(String?)
    
    case removeKeyword(index: Int)
  }
  
  struct State {
    
    var keywords: [String?] = []
    
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
    case let .addKeyword(keyword):
      return Observable.just(Mutation.addKeyword(keyword))
    case let .removeKeyword(index):
      return Observable.just(Mutation.removeKeyword(index: index))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setConfirmButtonSelection(isConfirmButtonSelected):
      state.isConfirmButtonSelected = isConfirmButtonSelected
    case let .setBackButtonSelection(isBackButtonSelected):
      state.isBackButtonSelected = isBackButtonSelected
    case let .addKeyword(keyword):
      state.keywords.append(keyword)
    case let .removeKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}
