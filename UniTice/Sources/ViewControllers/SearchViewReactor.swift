//
//  SearchViewReactor.swift
//  UniTice
//
//  Created by Presto on 05/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `SearchViewController`.
final class SearchViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the view is loaded in memory.
    case viewDidLoad
    
    /// The action that the user updates the text for searching.
    case updateSearchText(String?)
    
    /// The action that the user provokes searching.
    case search
    
    /// The action that the user scrolls the table view to load more posts.
    case scroll
    
    /// The action that the user interacts with the cell to check more information about the post.
    case interactWithCell(Post)
  }
  
  enum Mutation {
    
    /// The mutation to set the initial state.
    case viewDidLoad
    
    /// The mutation to set the search text.
    case setSearchText(String?)
    
    /// The mutation to set posts.
    case setPosts([Post])
    
    /// The mutation to append posts.
    case appendPosts([Post])
    
    /// The mutation to set the loading status.
    case setLoading(Bool)
    
    /// The mutation to save bookmark to realm.
    case saveBookmark(Post)
    
    /// The mutation to reset the page.
    case resetPage
    
    /// The mutation to increment the page.
    case incrementPage
  }
  
  struct State {
    
    /// The university.
    var university: UniversityType
    
    /// The category for searching.
    var category: Category
    
    /// The posts.
    var posts: [Post] = []
    
    /// The current page.
    var page: Int = 1
    
    /// The text for searching.
    var searchText: String = ""
    
    /// The boolean value indicating whether the post request task is in progress.
    var isLoading: Bool = false
    
    /// The boolean value indicating whether the view is presented.
    var isPresented: Bool = false
    
    var hasSearched: Bool = false
    
    init(university: UniversityType, category: Category) {
      self.university = university
      self.category = category
    }
  }
  
  let initialState: State
  
  /// The realm service.
  let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared,
       university: UniversityType,
       category: Category) {
    self.realmService = realmService
    initialState = .init(university: university, category: category)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable.just(Mutation.viewDidLoad)
    case let .interactWithCell(post):
      return saveBookmark(post)
    case let .updateSearchText(text):
      return Observable.just(Mutation.setSearchText(text))
    case .search:
      return Observable.concat([
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
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .resetPage:
      state.page = 1
    case .incrementPage:
      state.page += 1
    case .viewDidLoad:
      state.isPresented = true
    case let .setSearchText(text):
      state.searchText = text ?? ""
    case let .setPosts(posts):
      state.posts = posts
      state.hasSearched = true
    case let .appendPosts(posts):
      state.posts.append(contentsOf: posts)
    case let .setLoading(isLoading):
      state.isLoading = isLoading
    case .saveBookmark:
      break
    }
    return state
  }
}

// MARK: - Private Method

private extension SearchViewReactor {
  
  func requestPosts(byType type: PostRequstType, inPage page: Int) -> Observable<Mutation> {
    return currentState.university
      .requestPosts(inCategory: currentState.category,
                    inPage: page,
                    searchText: currentState.searchText)
      .map { $0.filter { $0.number != 0 } }
      .map {
        switch type {
        case .set:
          return Mutation.setPosts($0)
        case .append:
          return Mutation.appendPosts($0)
        }
    }
  }
  
  func saveBookmark(_ bookmark: Post) -> Observable<Mutation> {
    return realmService.addBookmark(bookmark).map { _ in Mutation.saveBookmark(bookmark) }
  }
}
