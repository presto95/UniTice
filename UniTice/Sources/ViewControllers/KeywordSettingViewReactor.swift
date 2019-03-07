//
//  KeywordSettingViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

/// 설정 키워드 설정 뷰 리액터.
final class KeywordSettingViewReactor: Reactor {
  
  enum Action {
    
    case didPresent
    
    case addKeyword(String?)

    case register
    
    case deleteKeyword(at: Int)
  }
  
  enum Mutation {
    
    case add

    case register
    
    case setKeywords([String])
    
    case addKeyword(String?)
    
    case deleteKeyword(at: Int)
  }
  
  struct State {
    
    var isAddButtonSelected: Bool = false
    
    var isRegisterButtonSelected: Bool = false
    
    var keywords: [String] = []
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return fetchSavedKeywords()
    case .touchUpAddButton:
      return Observable.concat([
        Observable.just(Mutation.setAddButtonSelection(true)),
        Observable.just(Mutation.setAddButtonSelection(false))
        ])
    case let .touchUpRegisterButton(keyword):
      return Observable.concat([
        Observable.just(Mutation.setRegisterButtonSelection(true)),
        saveKeyword(keyword),
        Observable.just(Mutation.setRegisterButtonSelection(false))
        ])
    case let .touchUpDeleteKeyword(index):
      
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setAddButtonSelection(isSelected):
      state.isAddButtonSelected = isSelected
    case let .initializeKeywords(keywords):
      state.keywords = keywords
    case let .addKeyword(keyword):
      state.keywords.insert(keyword, at: 0)
    case let .deleteKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}

// MARK: - Private Method

private extension KeywordSettingViewReactor {
  
  func fetchSavedKeywords() -> Observable<Mutation> {
    let keywords = Array(User.fetch()?.keywords.map { "\($0)" } ?? [])
    return Observable
      .just(keywords)
      .map { Mutation.initializeKeywords($0) }
  }
  
  func saveKeyword(_ keyword: String) -> Observable<Mutation> {
    let isDuplicated = User.insertKeyword(keyword)
    if isDuplicated {
      return Observable.just(keyword).map { Mutation.addKeyword($0) }
    } else {
      return Observable.just(Void()).map { Mutation.addKeyword }
    }
  }
}

