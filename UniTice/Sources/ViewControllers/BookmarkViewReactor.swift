//
//  BookmarkViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

/// 북마크 뷰 리액터.
final class BookmarkViewReactor: Reactor {
  
  enum Action {
    
    case viewDidLoad
    
    case deleteBookmark(Int)
  }
  
  enum Mutation {
    
    case initialize([Bookmark], [String])
    
    case deleteBookmark(Int)
  }
  
  struct State {
    
    var keywords: [String] = []
    
    var bookmarks: [Bookmark] = []
  }
  
  let initialState: State = State()
  
  let persistenceService: PersistenceServiceType
  
  init(persistenceService: PersistenceServiceType = PersistenceService.shared) {
    self.persistenceService = persistenceService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable
        .zip(persistenceService.fetchBookmarks(),
             persistenceService.fetchKeywords()) { Mutation.initialize($0, $1) }
    case let .deleteBookmark(item):
      return persistenceService.removeBookmark(at: item).map { Mutation.deleteBookmark(item) }
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
