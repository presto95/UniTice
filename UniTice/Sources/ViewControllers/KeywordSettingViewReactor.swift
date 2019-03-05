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

final class KeywordSettingViewReactor: Reactor {
  
  enum Action {
    
    case viewDidLoad
    
    case touchUpAddButton
    
    case touchUpRegisterButton(keyword: String)
    
    case touchUpDeleteKeyword(index: Int)
  }
  
  enum Mutation {
    
    case setAddButtonSelection(Bool)
    
    case setRegisterButtonSelection(Bool)
    
    case initializeKeywords([String])
    
    case addKeyword(String)
    
    case deleteKeyword(index: Int)
  }
  
  struct State {
    
    var isAddButtonSelected: Bool = false
    
    var isRegisterButtonSelected: Bool = false
    
    var keywords: [String] = []
    
    var numberOfKeywords: Int {
      return keywords.count
    }
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

