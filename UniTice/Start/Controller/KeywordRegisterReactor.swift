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
    
    case addKeyword(String?)
    
    case removeKeyword(index: Int)
  }
  
  enum Mutation {
    
    case addKeyword(String?)
    
    case removeKeyword(index: Int)
  }
  
  struct State {
    
    var keywords: [String?] = []
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .addKeyword(keyword):
      return Observable.just(Mutation.addKeyword(keyword))
    case let .removeKeyword(index):
      return Observable.just(Mutation.removeKeyword(index: index))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .addKeyword(keyword):
      state.keywords.append(keyword)
    case let .removeKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}
