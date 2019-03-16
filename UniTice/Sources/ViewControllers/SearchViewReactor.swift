//
//  SearchViewReactor.swift
//  UniTice
//
//  Created by Presto on 05/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

/// 검색 뷰 리액터.
final class SearchViewReactor: Reactor {
  
  enum Action {
    
    /// 표시됨.
    case didPresent
    
    /// 검색 텍스트 갱신.
    case updateSearchText(String?)
    
    /// 검색.
    case search
    
    /// 스크롤.
    case scroll
  }
  
  enum Mutation {
    
    case didPresent
    
    /// 검색 텍스트 설정.
    case setSearchText(String?)
    
    /// 게시물 설정.
    case setPosts([Post])
    
    /// 게시물 추가.
    case appendPosts([Post])
  }
  
  struct State {
    
    /// 카테고리.
    var category: Category = ("", "")
    
    /// 모든 게시물.
    var posts: [Post] = []
    
    /// 현재 페이지.
    var currentPage: Int = 1
    
    /// 검색 텍스트.
    var searchText: String = ""
    
    /// 씬이 표시된 상태인가.
    var isPresented: Bool = false
    
    /// 검색 상태에 있는가.
    var isSearching: Bool = false
  }
  
  /// 초기 상태.
  let initialState: State = State()
  
  let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared) {
    self.realmService = realmService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didPresent:
      return Observable.just(Mutation.didPresent)
    case let .updateSearchText(text):
      return Observable.just(Mutation.setSearchText(text))
    case .search:
      return requestPosts().map { Mutation.setPosts($0) }
    case .scroll:
      return requestPosts().map { Mutation.appendPosts($0) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .didPresent:
      state.isPresented = true
    case let .setSearchText(text):
      state.searchText = text ?? ""
    case let .setPosts(posts):
      state.posts = posts
    case let .appendPosts(posts):
      state.posts.append(contentsOf: posts)
    }
    return state
  }
}

// MARK: - Private Method

private extension SearchViewReactor {
  
  func requestPosts() -> Observable<[Post]> {
    return realmService.fetchUniversity()
      .map { $0.model }
      .flatMap { [weak self] universityModel -> Observable<[Post]> in
        guard let self = self else { return .empty() }
        return universityModel
          .requestPosts(inCategory: self.currentState.category,
                        inPage: self.currentState.currentPage,
                        searchText: self.currentState.searchText)
          .map { posts -> [Post] in
            return posts.filter { $0.number != 0 }
        }
    }
  }
}
