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
    
    var isLoading: Bool = false
    
    var fixedPosts: [Post] {
      return posts.filter { $0.number == 0 }
    }
    
    var standardPosts: [Post] {
      return posts.filter { $0.number != 0 }
    }
    
    init(university: UniversityType, category: Category) {
      self.university = university
      self.category = category
    }
  }
  
  let initialState: State
  
  init(university: UniversityType, category: Category) {
    initialState = State(university: university, category: category)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .toggleFolding(isFolded):
      return Observable.just(Mutation.toggleFolding(isFolded))
    case .viewDidLoad:
      return Observable.concat([
        Observable.just(Mutation.setLoading(true)),
        requestPosts(.set),
        Observable.just(Mutation.setLoading(false))
        ])
    case .scroll:
      return Observable.concat([
        Observable.just(Mutation.setLoading(true)),
        requestPosts(.append),
        Observable.just(Mutation.setLoading(false))
        ])
    case .refresh:
      return Observable.concat([
        Observable.just(Mutation.setLoading(true)),
        requestPosts(.set),
        Observable.just(Mutation.setLoading(false))
        ])
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
    return Global.shared.universityModel
      .flatMap { university -> Observable<[Post]> in
        return university.requestPosts(inCategory: self.currentState.category,
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
