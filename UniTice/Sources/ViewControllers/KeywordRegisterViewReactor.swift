//
//  KeywordRegisterReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

final class KeywordRegisterViewReactor: Reactor {
  
  enum Action {
    
    case confirm
    
    case back
    
    case inputKeyword(String?)
    
    case addKeyword
    
    case removeKeyword(index: Int)
  }
  
  enum Mutation {
    
    case confirm(Bool)
    
    case back(Bool)
    
    case setKeyword(String?)
    
    case addKeyword
    
    case removeKeyword(at: Int)
  }
  
  struct State {
    
    var currentKeyword: String?
    
    var keywords: [String] = []
    
    var isConfirmButtonSelected: Bool = false
    
    var isBackButtonSelected: Bool = false
  }
  
  let initialState: State = .init()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .confirm:
      return Observable.concat([
        Observable.just(Mutation.confirm(true)),
        Observable.just(Mutation.confirm(false))
        ])
    case .back:
      return Observable.concat([
        Observable.just(Mutation.back(true)),
        Observable.just(Mutation.back(false))
        ])
    case let .inputKeyword(keyword):
      return Observable.just(Mutation.setKeyword(keyword))
    case .addKeyword:
      return Observable.just(Mutation.addKeyword)
    case let .removeKeyword(index):
      return Observable.just(Mutation.removeKeyword(at: index))
    }  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .confirm(isSelected):
      state.isConfirmButtonSelected = isSelected
    case let .back(isSelected):
      state.isBackButtonSelected = isSelected
    case let .setKeyword(keyword):
      state.currentKeyword = keyword
    case .addKeyword:
      state.keywords.insert(state.currentKeyword ?? "", at: 0)
    case let .removeKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}
