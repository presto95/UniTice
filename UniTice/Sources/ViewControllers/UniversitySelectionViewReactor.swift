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
    
    case confirm
    
    case inquiry
  }
  
  enum Mutation {
    
    case setUniversity(University)
    
    case presentNext
    
    case presentMailComposer(Bool)
  }
  
  struct State {
    
    var university: University?
    
    var isPresentingNextScene: Bool = false
    
    var isInquiryButtonSelected: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .selectUniversity(university):
      return Observable.just(Mutation.setUniversity(university))
    case .confirm:
      return Observable.just(Mutation.presentNext)
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
    case .presentNext:
      state.isPresentingNextScene = true
    case let .presentMailComposer(isSelected):
      state.isInquiryButtonSelected = isSelected
    }
    return state
  }
}
