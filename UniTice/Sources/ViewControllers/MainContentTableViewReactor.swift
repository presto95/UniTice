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

/// The `Reactor` for `MainContentTableViewController`.
final class MainContentTableViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the view is loaded in memory.
    case viewDidLoad
    
    /// The action that the user scrolls the table view to load more posts.
    case scroll
    
    /// The action that the user swipes the table view to reload posts.
    case refresh
    
    /// The action that the user taps the arrow button to fold or unfold the upper posts.
    case toggleFolding(Bool)
  }
  
  enum Mutation {
    
    case toggleFolding(Bool)
    
    case setPosts([Post])
    
    case appendPosts([Post])
    
    case setLoading(Bool)
  }
  
  struct State {
    
    var university: UniversityType
    
    var category: Category
    
    var page: Int = 1
    
    var keywords: [String] = []
    
    var posts: [Post] = []
    
    var isFixedNoticeFolded: Bool = false
    
    var isLoading: Bool = true
    
    var fixedPosts: [Post] {
      return posts.filter { $0.number == 0 }
    }

    var standardPosts: [Post] {
      return posts.filter { $0.number != 0 }
    }
    
    init(universityType: UniversityType, category: Category) {
      self.universityType = universityType
      self.category = category
    }
  }
  
  let initialState: State
  
  init(universityType: UniversityType, category: Category) {
    initialState = State(universityType: universityType, category: category)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .toggleFolding(isFolded):
      return Observable.just(Mutation.toggleFolding(isFolded))
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
    case let .toggleFolding(isFolded):
      state.isFixedNoticeFolded = isFolded
    case let .setPosts(posts):
      state.posts = posts
      state.page += 1
    case let .appendPosts(posts):
      state.posts.append(contentsOf: posts)
      state.page += 1
    case let .setLoading(isLoading):
      state.isLoading = isLoading
    }
    return state
  }
}

// MARK: - Private Method

private extension MainContentTableViewReactor {
  
  func requestPosts(_ type: PostRequstType) -> Observable<Mutation> {
    let requestObservable = Global.shared.universityModel
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
    return Observable.concat([
      Observable.just(Mutation.setLoading(true)),
      requestPosts,
      Observable.just(Mutation.setLoading(false))
      ])
  }
}
