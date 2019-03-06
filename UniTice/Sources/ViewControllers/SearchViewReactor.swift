//
//  SearchViewReactor.swift
//  UniTice
//
//  Created by Presto on 05/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

final class SearchViewReactor: Reactor {
  
  enum Action {
    
    case search
  }
  
  enum Mutation {
    
    case requestPosts(searchText: String)
  }
  
  struct State {
    
    var posts: [Post] = []
    
    var page: Int = 1
    
    var isSearchButtonTapped: Bool = false
    
    var searchText: String = ""
    
    var category: (identifier: String, description: String) = ("", "")
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .search:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .requestPosts(searchText):
      break
    }
    return state
  }
}
