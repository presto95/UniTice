//
//  UniversityChangeReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class UniversityChangeViewReactor: Reactor {
  
  enum Action {
    
    case changeUniversity(University)
    
    case confirm
  }
  
  enum Mutation {
    
    case setUniversity(University)
    
    case confirm
    
    //case setConfirmButtonSelection(Bool)
  }
  
  struct State {
    
    var university: University?
    
    var isConfirmButtonSelected: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .changeUniversity(university):
      return Observable.just(Mutation.setUniversity(university))
    case .confirm:
      return Observable.just(Mutation.confirm)
//      return Observable.concat([
//        Observable.just(Mutation.setConfirmButtonSelection(true)),
//        resetUniversity(),
//        Observable.just(Mutation.setConfirmButtonSelection(false))
//        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setUniversity(university):
      state.university = university
    case .confirm:
      state.isConfirmButtonSelected = true
//    case let .setConfirmButtonSelection(isSelected):
//      state.isConfirmButtonSelected = isSelected
    }
    return state
  }
}

// MARK: - Private Method

private extension UniversityChangeViewReactor {
  
  func resetUniversity() -> Observable<Mutation> {
    let university = currentState.university ?? .kaist
    User.updateUniversity(university.rawValue)
    User.removeBookmarksAll()
    User.removeKeywordsAll()
    UniversityModel.shared.generateModel()
    return .empty()
  }
}
