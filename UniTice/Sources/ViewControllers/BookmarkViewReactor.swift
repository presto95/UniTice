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

struct BookmarkSectionData {
  
  var title: String
  
  var date: String
}

struct BookmarkSection {
  
  var items: [Item]
}

extension BookmarkSection: SectionModelType {
  
  typealias Item = BookmarkSectionData
  
  init(original: BookmarkSection, items: [Item]) {
    self = original
    self.items = items
  }
}

final class BookmarkViewReactor: Reactor {
  
  enum Action {
    
    case viewDidLoad
    
    case deleteBookmark(Int)
  }
  
  enum Mutation {
    
    case setBookmarks([Bookmark])
    
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
      return persistenceService.fetchBookmarks().map { Mutation.setBookmarks($0) }
    case let .deleteBookmark(item):
      return persistenceService.removebook
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setBookmarks:
    case let .deleteBookmark(item):
    }
  }
}
