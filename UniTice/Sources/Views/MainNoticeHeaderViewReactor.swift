//
//  MainNoticeHeaderViewReactor.swift
//  UniTice
//
//  Created by Presto on 03/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `MainNoticeHeaderView`.
final class MainNoticeHeaderViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the user toggles the fold button.
    case toggleFolding
  }
  
  enum Mutation {
    
    /// The mutation to toggle the folding status.
    case toggleFolding
  }
  
  struct State {
    
    /// The boolean value indicating whether the upper posts are folded.
    var isUpperPostFolded: Bool
  }
  
  let initialState: State
  
  /// The user defaults service.
  private let userDefaultsService: UserDefaultsServiceType
  
  init(userDefaultsService: UserDefaultsServiceType = UserDefaultsService.shared) {
    self.userDefaultsService = userDefaultsService
    initialState = .init(isUpperPostFolded: userDefaultsService.isUpperPostFolded)
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
      state.isUpperPostFolded.toggle()
    }
    return state
  }
}
