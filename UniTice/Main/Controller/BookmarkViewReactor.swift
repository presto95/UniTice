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
import RxSwift

final class BookmarkViewReactor: Reactor {
  
  enum Action {
    
    case viewDidLoad
    
    case deleteBookmark(Int)
  }
  
  enum Mutation {
    
    case setBookmark([Bookmark])
  }
  
  struct State {
    
    var keywords: [String] = []
    
    var bookmarks: [Bookmark] = []
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    
  }
}
