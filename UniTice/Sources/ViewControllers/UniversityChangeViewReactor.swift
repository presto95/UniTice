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
    
    /// The action that the user changes the university.
    case changeUniversity(University)
    
    /// The action that the user taps the confirm button.
    case confirm
  }
  
  enum Mutation {
    
    /// The mutation to set the university.
    case setUniversity(University)
    
    /// The mutation to set the confirmation status.
    case confirm
  }
  
  struct State {
    
    /// The selected university.
    var university: University?
    
    /// The boolean value indicating whether the confirm button is tapped.
    var isConfirmButtonTapped: Bool = false
  }
  
  let initialState: State = .init()
  
  /// The realm service.
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
      state.isConfirmButtonTapped = true
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
