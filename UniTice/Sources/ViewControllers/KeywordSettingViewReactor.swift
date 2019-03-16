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
    
    /// 뷰가 화면에 나타남.
    case viewDidLoad
    
    /// 뷰에서 키워드 추가 버튼 누름.
    case register
    
    /// 얼러트에서 확인 버튼 누름.
    case alertConfirm(String?)
    
    case alertCancel

    /// 뷰에서 키워드 삭제.
    case deleteKeyword(index: Int)
  }
  
  enum Mutation {
    
    case presentAlert
    
    case dismissAlert
    
    /// 초기 키워드 설정.
    case setKeywords([String])
    
    /// 키워드 추가.
    case addKeyword(String?)
    
    /// 키워드 삭제.
    case deleteKeyword(index: Int)
  }
  
  struct State {
    
    var keywords: [String] = []
    
    var isAlertPresenting: Bool = false
  }
  
  let initialState: State = State()
  
  let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared) {
    self.realmService = realmService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return realmService.fetchKeywords().map { Mutation.setKeywords($0) }
    case .register:
      return Observable.just(Mutation.presentAlert)
    case let .alertConfirm(keyword):
      return realmService.addKeyword(keyword).map { Mutation.addKeyword($0) }
    case .alertCancel:
      return Observable.just(Mutation.dismissAlert)
    case let .deleteKeyword(index):
      return realmService.removeKeyword(at: index).map { Mutation.deleteKeyword(index: index) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .presentAlert:
      state.isAlertPresenting = true
    case .dismissAlert:
      state.isAlertPresenting = false
    case let .setKeywords(keywords):
      state.keywords = keywords
    case let .addKeyword(keyword):
      state.keywords.insert(keyword ?? "", at: 0)
      state.isAlertPresenting = false
    case let .deleteKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}
