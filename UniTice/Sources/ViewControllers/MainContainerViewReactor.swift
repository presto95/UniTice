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

final class MainContainerViewReactor: Reactor {
  
  enum Action {
    
    case setting
    
    case search
    
    case bookmark
  }
  
  enum Mutation {
    
    case presentSetting(Bool)
    
    case presentSearch(Bool)
    
    case presentBookmark(Bool)
  }
  
  struct State {
    
    var isSettingButtonTapped = false
    
    var isSearchButtonTapped = false
    
    var isBookmarkButtonTapped = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setting:
      return Observable.concat([
        Observable.just(Mutation.presentSetting(true)),
        Observable.just(Mutation.presentSetting(false)),
        ])
    case .search:
      return Observable.concat([
        Observable.just(Mutation.presentSearch(true)),
        Observable.just(Mutation.presentSearch(false)),
        ])
    case .bookmark:
      return Observable.concat([
        Observable.just(Mutation.presentBookmark(true)),
        Observable.just(Mutation.presentBookmark(false)),
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
