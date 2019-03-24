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

/// The `Reactor` for `UniversitySelectionViewController`.
final class UniversitySelectionViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the user select the university.
    case selectUniversity(University)
    
    /// The action that the user taps the confirm button.
    case confirm
    
    /// The action that the user taps the inquiry button.
    case inquiry
  }
  
  enum Mutation {
    
    /// The mutation to set the university.
    case setUniversity(University)
    
    /// The mutation to present the next view.
    case confirm(Bool)
    
    /// The mutation to presetn the mail composer view.
    case inquiry(Bool)
  }
  
  struct State {
    
    /// The selected university.
    var university: University?
    
    /// The boolean value indicating whether the confirm button is selected.
    var isConfirmButtonSelected: Bool = false
    
    /// The boolean value indicating whether the inquiry button is selected.
    var isInquiryButtonSelected: Bool = false
  }
  
  let initialState: State = .init()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .selectUniversity(university):
      return Observable.just(Mutation.setUniversity(university))
    case .confirm:
      return Observable.concat([
        Observable.just(Mutation.confirm(true)),
        holdUniversity(currentState.university ?? .kaist),
        Observable.just(Mutation.confirm(false))
        ])
    case .inquiry:
      return Observable.concat([
        Observable.just(Mutation.inquiry(true)),
        Observable.just(Mutation.inquiry(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setUniversity(university):
      state.university = university
    case let .confirm(isSelected):
      state.isConfirmButtonSelected = isSelected
    case let .inquiry(isSelected):
      state.isInquiryButtonSelected = isSelected
    }
    return state
  }
}

// MARK: - Private Method

private extension UniversitySelectionViewReactor {
  
  /// Holds the university in the initial singleton object.
  func holdUniversity(_ university: University) -> Observable<Mutation> {
    InitialInfo.shared.university.onNext(university)
    return Observable.empty()
  }
}
