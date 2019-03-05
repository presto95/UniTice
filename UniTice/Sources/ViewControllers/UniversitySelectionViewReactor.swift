//
//  UniversitySelectionReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class UniversitySelectionViewReactor: Reactor {
  
  enum Action {
    
    case selectUniversity(University)
    
    case touchUpConfirmButton
    
    case touchUpNoticeButton
  }
  
  enum Mutation {
    
    case setUniversity(University)
    
    case setConfirmButtonSelection(Bool)
    
    case setInfoButtonSelection(Bool)
  }
  
  struct State {
    
    var university: University?
    
    var isConfirmButtonSelected: Bool = false
    
    var isInfoButtonSelected: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .selectUniversity(university):
      return Observable.just(Mutation.setUniversity(university))
    case .touchUpConfirmButton:
      return Observable.concat([
        Observable.just(Mutation.setConfirmButtonSelection(true)),
        Observable.just(Mutation.setConfirmButtonSelection(false))
        ])
    case .touchUpNoticeButton:
      return Observable.concat([
        Observable.just(Mutation.setInfoButtonSelection(true)),
        Observable.just(Mutation.setInfoButtonSelection(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setUniversity(university):
      state.university = university
    case let .setConfirmButtonSelection(isConfirmButtonSelected):
      state.isConfirmButtonSelected = isConfirmButtonSelected
    case let .setInfoButtonSelection(isInfoButtonSelected):
      state.isInfoButtonSelected = isInfoButtonSelected
    }
    return state
  }
}
