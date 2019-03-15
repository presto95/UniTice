//
//  MainContentTableViewReactor.swift
//  UniTice
//
//  Created by Presto on 07/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

enum PostRequstType {
  
  case set
  
  case append
}

final class MainContentTableViewReactor: Reactor {
  
  enum Action {
    
    case viewDidLoad
    
    case scroll
    
    case refresh
  }
  
  enum Mutation {
    
    case setPosts([Post])
    
    case appendPosts([Post])
  }
  
  struct State {
    
    var category: Category = ("", "")
    
    var categoryIndex: Int!
    
    var page: Int = 1
    
    var keywords: [String] = []
    
    var posts: [Post] = []
    
    var isFixedNoticeFolded: Bool = false
    
    var fixedPosts: [Post] {
      return posts.filter { $0.number == 0 }
    }
    
    var standardPosts: [Post] {
      return posts.filter { $0.number != 0 }
    }
  }
  
  let initialState: State
  
  init(page: Int) {
    var state = State()
    state.page = page
    initialState = state
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return requestPosts(.set)
    case .scroll:
      return requestPosts(.append)
    case .refresh:
      return requestPosts(.set)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setPosts(posts):
      state.posts = posts
    case let .appendPosts(posts):
      state.posts.append(contentsOf: posts)
    }
    return state
  }
}

// MARK: - Private Method

private extension MainContentTableViewReactor {
  
  func requestPosts(_ type: PostRequstType) -> Observable<Mutation> {
    return Global.shared.universityModel
      .flatMap { universityType -> Observable<[Post]> in
        return universityType.requestPosts(inCategory: self.currentState.category,
                                           inPage: self.currentState.page,
                                           searchText: "")
      }
      .map {
        switch type {
        case .set:
          return Mutation.setPosts($0)
        case .append:
          return Mutation.appendPosts($0)
        }
    }
  }
}
