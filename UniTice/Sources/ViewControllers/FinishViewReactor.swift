//
//  FinishViewReactor.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

/// 초기 설정 완료 뷰 리액터.
final class FinishViewReactor: Reactor {
  
  enum Action {
    
    case confirm
    
    case back
  }
  
  enum Mutation {
    
    case confirm
    
    case back
    
    case saveInitialData
  }
  
  struct State {
    
    var isConfirmButtonSelected: Bool = false
    
    var isBackButtonSelected: Bool = false
  }
  
  let initialState: State = State()
  
  let persistenceService: PersistenceServiceType
  
  init(persistenceService: PersistenceServiceType = PersistenceService.shared) {
    self.persistenceService = persistenceService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .confirm:
      return Observable.concat([
        saveUser(),
        Observable.just(Mutation.confirm)
        ])
    case .back:
      return Observable.just(Mutation.back)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .confirm:
      state.isConfirmButtonSelected = true
    case .back:
      state.isBackButtonSelected = true
    case .saveInitialData:
      break
    }
    return state
  }
}

// MARK: - Private Method

private extension FinishViewReactor {
  
  func saveUser() -> Observable<Mutation> {
    return Observable
      .zip(InitialInfo.shared.university,
           InitialInfo.shared.keywords) { [weak self] university, keywords in
            let user = User()
            user.university = university.rawValue
            user.keywords.append(objectsIn: keywords)
            self?.persistenceService.addUser(user)
            return Mutation.saveInitialData
    }
  }
}
