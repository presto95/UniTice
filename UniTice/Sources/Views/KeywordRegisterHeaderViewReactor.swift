//
//  KeywordRegisterHeaderViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxOptional
import RxSwift

final class KeywordRegisterHeaderViewReactor: Reactor {
  
  enum Action {
    
    case tapTextField
    
    case returnTextField
    
    case input(String?)
  
    case add
  }
  
  enum Mutation {
    
    case setTextFieldSelection(Bool)
    
    case setKeyword(String?)
    
    case addKeyword(String)
  }
  
  struct State {
    
    var isTextFieldSelected: Bool = false
    
    var currentKeyword: String?
    
    var keywords: [String] = []
  }
  
  let initialState: State = .init()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .tapTextField:
      return Observable.just(Mutation.setTextFieldSelection(true))
    case .returnTextField:
      return Observable.just(Mutation.setTextFieldSelection(false))
    case let .input(keyword):
      return Observable.just(Mutation.setKeyword(keyword))
    case .add:
      return Observable.just(currentState.currentKeyword)
        .filterNil()
        .map { $0.replacingOccurrences(of: " ", with: "") }
        .map { Mutation.addKeyword($0) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setTextFieldSelection(isSelected):
      state.isTextFieldSelected = isSelected
    case let .setKeyword(keyword):
      state.currentKeyword = keyword
    case let .addKeyword(keyword):
      state.keywords.insert(keyword, at: 0)
      state.currentKeyword = nil
    }
    return state
  }
}
