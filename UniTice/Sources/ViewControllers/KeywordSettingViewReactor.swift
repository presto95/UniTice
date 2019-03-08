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
    case didPresent
    
    /// 뷰에서 키워드 추가 버튼 누름.
    case register
    
    /// 얼러트에서 확인 버튼 누름.
    case alertConfirm(String?)
    
    /// 얼러트에서 취소 버튼 누름.
    case alertCancel

    /// 뷰에서 키워드 삭제.
    case deleteKeyword(at: Int)
  }
  
  enum Mutation {

    /// 키워드 추가 얼러트 띄움.
    case presentAlert
    
    /// 얼러트 숨기기.
    case dismissAlert
    
    /// 초기 키워드 설정.
    case setKeywords([String])
    
    /// 키워드 추가.
    case addKeyword(String?)
    
    /// 키워드 삭제.
    case deleteKeyword(at: Int)
  }
  
  struct State {
    
    var keywords: [String] = []
  }
  
  let initialState: State = State()
  
  let persistenceService: PersistenceServiceType
  
  init(persistenceService: PersistenceServiceType = PersistenceService.shared) {
    self.persistenceService = persistenceService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didPresent:
      return persistenceService.fetchKeywords().map { Mutation.setKeywords($0) }
    case .register:
      return Observable.just(Mutation.presentAlert)
    case let .alertConfirm(keyword):
      return persistenceService.addKeyword(keyword)
        .map { Mutation.addKeyword($0) }
    case .alertCancel:
      return Observable.just(Mutation.dismissAlert)
    case let .deleteKeyword(index):
      return persistenceService.removeKeyword(at: index).map { Mutation.deleteKeyword(at: index) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setKeywords(keywords):
      state.keywords = keywords
    case let .addKeyword(keyword):
      state.keywords.insert(keyword ?? "", at: 0)
    case let .deleteKeyword(index):
      state.keywords.remove(at: index)
    default:
      break
    }
    return state
  }
}
