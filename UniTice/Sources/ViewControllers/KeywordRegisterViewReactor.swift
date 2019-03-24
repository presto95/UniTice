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
    
    /// The mutation to set the tap status of the confirm button.
    case confirm(Bool)
    
    /// The mutation to set the tap status of the back button.
    case back(Bool)
    
    /// The mutation to add the keyword.
    case addKeyword(String)
    
    /// The mutaiton to remove the keyword at `index`.
    case removeKeyword(index: Int)
  }
  
  struct State {
    
    /// The keywords.
    var keywords: [String] = []
    
    /// The boolean value indicating whether the confirm button is tapped.
    var isConfirmButtonTapped: Bool = false
    
    /// The boolean value indicating whether the back button is tapped.
    var isBackButtonTapped: Bool = false
  }
  
  let initialState: State = .init()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .confirm:
      return Observable.concat([
        Observable.just(Mutation.confirm(true)),
        holdKeywords(currentState.keywords),
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
      state.isConfirmButtonTapped = isSelected
    case let .back(isSelected):
      state.isBackButtonTapped = isSelected
    case let .addKeyword(keyword):
      if state.keywords.count >= 3 { break }
      state.keywords.insert(keyword, at: 0)
    case let .removeKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}

// MARK: - Private Method

private extension KeywordRegisterViewReactor {
  
  /// Holds the keywords in the initial singleton object.
  func holdKeywords(_ keywords: [String]) -> Observable<Mutation> {
    InitialInfo.shared.keywords.onNext(keywords)
    return Observable.empty()
  }
}
