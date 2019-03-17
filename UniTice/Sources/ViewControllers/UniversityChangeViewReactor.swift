//
//  UniversityChangeReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `UniversityChangeViewController`.
final class UniversityChangeViewReactor: Reactor {
  
  enum Action {
    
    /// 대학교 변경.
    case changeUniversity(University)
    
    /// 확인.
    case confirm
  }
  
  enum Mutation {
    
    /// 대학교 설정.
    case setUniversity(University)
    
    /// 확인.
    case confirm
  }
  
  struct State {
    
    /// 대학교.
    var university: University?
    
    /// 확인 버튼이 선택된 상태인가.
    var isConfirmButtonSelected: Bool = false
  }
  
  /// 초기 상태.
  let initialState: State = .init()
  
  /// 데이터 보존 서비스.
  let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared) {
    self.realmService = realmService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .changeUniversity(university):
      return Observable.just(Mutation.setUniversity(university))
    case .confirm:
      return Observable.concat([
        resetUniversity(),
        Observable.just(Mutation.confirm)
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setUniversity(university):
      state.university = university
    case .confirm:
      state.isConfirmButtonSelected = true
    }
    return state
  }
}

// MARK: - Private Method

private extension UniversityChangeViewReactor {
  
  func resetUniversity() -> Observable<Mutation> {
    let university = currentState.university ?? .kaist
    Global.shared.university.onNext(university)
    return Observable
      .combineLatest(realmService.updateUniversity(university),
                     realmService.removeAllKeywords(),
                     realmService.removeAllBookmarks()) { _, _, _ in
                      return Mutation.confirm
    }
  }
}
