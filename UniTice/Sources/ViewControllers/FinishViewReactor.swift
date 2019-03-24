//
//  FinishViewReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `FinishViewController`.
final class FinishViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the user taps the confirm button.
    case confirm
    
    /// The action that the user taps the back button.
    case back
  }
  
  enum Mutation {
    
    /// The mutation to set the tapping status of the confirm button.
    case confirm(Bool)
    
    /// The mutation to set the tapping status of the back button.
    case back(Bool)
    
  }
  
  struct State {
    
    /// The boolean value indicating whether the confirm button is selected.
    var isConfirmButtonTapped: Bool = false
    
    /// The boolean value indicating whether the back button is selected.
    var isBackButtonTapped: Bool = false
  }
  
  let initialState: State = .init()
  
  /// The realm service.
  private let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared) {
    self.realmService = realmService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .confirm:
      return Observable.concat([
        saveUser(),
        Observable.just(Mutation.confirm(true)),
        Observable.just(Mutation.confirm(false))
        ])
    case .back:
      return Observable.concat([
        Observable.just(Mutation.back(true)),
        Observable.just(Mutation.back(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .confirm(isTapped):
      state.isConfirmButtonTapped = isTapped
    case let .back(isTapped):
      state.isBackButtonTapped = isTapped
    }
    return state
  }
}

// MARK: - Private Method

private extension FinishViewReactor {
  
  func saveUser() -> Observable<Mutation> {
    let university = InitialInfo.shared.university
    let keywords = InitialInfo.shared.keywords
    return Observable
      .combineLatest(university, keywords) { [weak self] university, keywords in
        let user = User().then {
          $0.university = university.rawValue
          $0.keywords.append(objectsIn: keywords)
        }
        self?.realmService.addUser(user)
        Global.shared.university.onNext(university)
      }
      .take(1)
      .flatMap { _ in Observable.empty() }
  }
}
