//
//  BookmarkViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `BookmarkViewController`.
final class BookmarkViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the view is loaded in memory.
    case viewDidLoad
    
    /// The action that the user provokes deleting the bookmark at `index`.
    case deleteBookmark(index: Int)
  }
  
  enum Mutation {
    
    /// The mutation to initialize bookmarks and keywords.
    case initialize([Bookmark], [String])
    
    /// The mutation to delete bookmark at `index`.
    case deleteBookmark(index: Int)
  }
  
  struct State {
    
    /// The keyword string values.
    var keywords: [String] = []
    
    /// The bookmark objects.
    var bookmarks: [Bookmark] = []
  }
  
  let initialState: State = .init()
  
  /// The realm service.
  private let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared) {
    self.realmService = realmService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable
        .combineLatest(realmService.fetchBookmarks(), realmService.fetchKeywords()) {
          Mutation.initialize($0, $1)
      }
    case let .deleteBookmark(item):
      return realmService.removeBookmark(at: item).map { Mutation.deleteBookmark(index: item) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .initialize(bookmarks, keywords):
      state.bookmarks = bookmarks
      state.keywords = keywords
    case let .deleteBookmark(item):
      state.bookmarks.remove(at: item)
    }
    return state
  }
}
