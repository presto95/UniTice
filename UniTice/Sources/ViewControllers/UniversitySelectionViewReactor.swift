//
//  UniversitySelectionReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// 초기 대학교 설정 뷰 리액터.
final class UniversitySelectionViewReactor: Reactor {
  
  enum Action {
    
    /// 대학교 선택.
    case selectUniversity(University)
    
    /// 확인.
    case confirm
    
    /// 문의.
    case inquiry
  }
  
  enum Mutation {
    
    /// 대학교 설정.
    case setUniversity(University)
    
    /// 다음 화면 보이기.
    case presentNext(Bool)
    
    /// 메일 화면 보이기.
    case presentMailComposer(Bool)
  }
  
  struct State {
    
    /// 대학교.
    var university: University?
    
    /// 다음 화면을 보여준 상태인가.
    var isNextScenePresented: Bool = false
    
    /// 문의 버튼이 선택되어 있는 상태인가.
    var isInquiryButtonSelected: Bool = false
  }
  
  /// 초기 상태.
  let initialState: State = .init()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .selectUniversity(university):
      return Observable.just(Mutation.setUniversity(university))
    case .confirm:
      return Observable.concat([
        Observable.just(Mutation.presentNext(true)),
        Observable.just(Mutation.presentNext(false))
        ])
    case .inquiry:
      return Observable.concat([
        Observable.just(Mutation.presentMailComposer(true)),
        Observable.just(Mutation.presentMailComposer(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setUniversity(university):
      state.university = university
    case let .presentNext(isSelected):
      state.isNextScenePresented = isSelected
    case let .presentMailComposer(isSelected):
      state.isInquiryButtonSelected = isSelected
    }
    return state
  }
}
