//
//  MainContainerViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

/// The `Reactor` used by `MainContainerViewController`.
final class MainContainerViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the user taps the setting bar button item.
    case setting
    
    /// The action that the user taps the search bar button item.
    case search
    
    /// The action that the user taps the bookmark bar button item.
    case bookmark
  }
  
  enum Mutation {
    
    /// The mutation that sets up whether the setting scene is presented.
    case presentSetting(Bool)
    
    /// The mutation that sets up whether the search scene is presented.
    case presentSearch(Bool)
    
    /// The mutation that sets up whether the bookmark scene is presented.
    case presentBookmark(Bool)
  }
  
  struct State {
    
    /// The boolean value indicating whether the setting bar button item is tapped.
    var isSettingButtonTapped = false
    
    /// The boolean value indicating whether the search bar button item is tapped.
    var isSearchButtonTapped = false
    
    /// The boolean value indicating whether the bookmark bar button item is tapped.
    var isBookmarkButtonTapped = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setting:
      return .concat([
        .just(.presentSetting(true)),
        .just(.presentSetting(false))
        ])
    case .search:
      return .concat([
        .just(.presentSearch(true)),
        .just(.presentSearch(false))
        ])
    case .bookmark:
      return .concat([
        .just(.presentBookmark(true)),
        .just(.presentBookmark(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .presentSetting(isTapped):
      state.isSettingButtonTapped = isTapped
    case let .presentSearch(isTapped):
      state.isSearchButtonTapped = isTapped
    case let .presentBookmark(isTapped):
      state.isBookmarkButtonTapped = isTapped
    }
    return state
  }
}
