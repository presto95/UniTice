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

/// The `Reactor` for `KeywordRegisterView`.
final class KeywordRegisterViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the user taps the confirm button.
    case confirm
    
    /// The action that the user taps the back button.
    case back
    
    /// The action that the user returns the keyboard.
    case returnKeyboard(String)
    
    /// The action that the user removes the `index`th keyword.
    case removeKeyword(index: Int)
  }
  
  enum Mutation {
    
    case confirm(Bool)
    
    case back(Bool)
    
    case addKeyword(String)
    
    case removeKeyword(index: Int)
  }
  
  struct State {
    
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
    case let .returnKeyboard(keyword):
      return Observable.just(Mutation.addKeyword(keyword))
    case let .removeKeyword(index):
      return Observable.just(Mutation.removeKeyword(index: index))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .confirm(isSelected):
      state.isConfirmButtonSelected = isSelected
    case let .back(isSelected):
      state.isBackButtonSelected = isSelected
    case let .addKeyword(keyword):
      state.keywords.insert(keyword, at: 0)
    case let .removeKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}
