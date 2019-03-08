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

final class MainContentTableViewReactor: Reactor {
  
  enum Action {
    
  }
  
  enum Mutation {
    
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
  
  func mutate(action: Action) -> Observable<Mutation> {
    
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    
  }
}

// MARK: - Private Method

private extension MainContentTableViewReactor {
  
  func requestPosts() -> Observable<[Post]> {
    
  }
}
