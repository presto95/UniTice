//
//  MainContentTableViewReactor.swift
//  UniTice
//
//  Created by Presto on 07/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

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
    
    /// The action that the user interacts with the cell to check more information about the post.
    case interactWithCell(Post)
  }
  
  enum Mutation {
    
    /// The mutation to toggle the upper post folding status.
    case toggleFolding(Bool)
    
    /// The mutation to set posts.
    case setPosts([Post])
    
    /// The mutation to append posts.
    case appendPosts([Post])
    
    /// The mutation to set the refreshing status.
    case setRefreshing(Bool)
    
    /// The mutation to set the loading status.
    case setLoading(Bool)
    
    /// The mutation to set keywords.
    case setKeywords([String])
    
    /// The mutation to set the upper post folding status.
    case setUpperPostFoldingStatus(Bool)
    
    /// The mutation to reset the page.
    case resetPage
    
    /// The mutation to increment the page.
    case incrementPage
  }
  
  struct State {
    
    /// The university.
    var university: UniversityType
    
    /// The category of the content view.
    var category: Category
    
    /// The current page.
    var page: Int = 1
    
    /// The keywords to highlight the interested post.
    var keywords: [String] = []
    
    /// The posts.
    var posts: [Post] = []
    
    /// The boolean value indicating whether the upper post is folded.
    var isUpperPostFolded: Bool?
    
    /// The boolean value indicating whether the table view is refreshing.
    var isRefreshing: Bool = false
    
    /// The boolean value indicating whether the post request task is in progress.
    var isLoading: Bool = false
    
    /// The upper posts.
    var upperPosts: [Post] {
      return posts.filter { $0.number == 0 }
    }
    
    /// The standard posts.
    var standardPosts: [Post] {
      return posts.filter { $0.number != 0 }
    }
    
    init(university: UniversityType, category: Category) {
      self.university = university
      self.category = category
    }
  }
  
  let initialState: State
  
  /// The realm service.
  let realmService: RealmServiceType
  
  let userDefaultsService: UserDefaultsServiceType
  
  init(realmService: RealmServiceType = RealmService.shared,
       userDefaultsService: UserDefaultsServiceType = UserDefaultsService.shared,
       university: UniversityType,
       category: Category) {
    self.realmService = realmService
    self.userDefaultsService = userDefaultsService
    initialState = .init(university: university,
                         category: category)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable.concat([
        fetchKeywords(),
        fetchUpperPostFoldingStatus(),
        Observable.just(Mutation.setLoading(true)),
        requestPosts(byType: .set, inPage: 1),
        Observable.just(Mutation.resetPage),
        Observable.just(Mutation.setLoading(false))
        ])
    case .scroll:
      return Observable.concat([
        Observable.just(Mutation.setLoading(true)),
        requestPosts(byType: .append, inPage: currentState.page + 1),
        Observable.just(Mutation.incrementPage),
        Observable.just(Mutation.setLoading(false))
        ])
    case .refresh:
      return Observable.concat([
        Observable.just(Mutation.setRefreshing(true)),
        requestPosts(byType: .set, inPage: 1),
        Observable.just(Mutation.resetPage),
        Observable.just(Mutation.setRefreshing(false))
        ])
    case let .toggleFolding(isFolded):
      return Observable.just(Mutation.toggleFolding(isFolded))
    case let .interactWithCell(post):
      return saveBookmark(post)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setRefreshing(isRefreshing):
      state.isRefreshing = isRefreshing
    case .resetPage:
      state.page = 1
    case .incrementPage:
      state.page += 1
    case let .toggleFolding(isFolded):
      state.isUpperPostFolded = isFolded
    case let .setPosts(posts):
      state.posts = posts
    case let .appendPosts(posts):
      state.posts.append(contentsOf: posts)
    case let .setLoading(isLoading):
      state.isLoading = isLoading
    case let .setKeywords(keywords):
      state.keywords = keywords
    case let .setUpperPostFoldingStatus(isFolded):
      state.isUpperPostFolded = isFolded
    }
    return state
  }
}

// MARK: - Private Method

private extension MainContentTableViewReactor {
  
  func requestPosts(byType type: PostRequstType, inPage page: Int) -> Observable<Mutation> {
    return currentState.university
      .requestPosts(inCategory: currentState.category,
                    inPage: page,
                    searchText: "")
      .map { posts -> [Post] in
        if case .append = type,
          posts.first?.title == self.currentState.upperPosts.first?.title {
          return posts.filter { $0.number != 0 }
        }
        return posts
      }
      .map {
        switch type {
        case .set: return Mutation.setPosts($0)
        case .append: return Mutation.appendPosts($0)
        }
    }
  }
  
  func fetchKeywords() -> Observable<Mutation> {
    return realmService.fetchKeywords().map { Mutation.setKeywords($0) }
  }
  
  func fetchUpperPostFoldingStatus() -> Observable<Mutation> {
    return Observable
      .just(Mutation.setUpperPostFoldingStatus(userDefaultsService.isUpperPostFolded))
  }
  
  func saveBookmark(_ bookmark: Post) -> Observable<Mutation> {
    return realmService.addBookmark(bookmark).flatMap { _ in Observable.empty() }
  }
}
