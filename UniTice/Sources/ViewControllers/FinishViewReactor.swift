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
    
    case confirm(Bool)
    
    case back(Bool)
    
    case saveInitialData
  }
  
  struct State {
    
    var isConfirmButtonTapped: Bool = false
    
    var isBackButtonTapped: Bool = false
  }
  
  let initialState: State = State()
  
  let realmService: RealmServiceType
  
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
            let user = User().then {
              $0.university = university.rawValue
              $0.keywords.append(objectsIn: keywords)
            }
            self?.realmService.addUser(user)
            Global.shared.university.onNext(university)
            return Mutation.saveInitialData
    }
    .take(1)
  }
}
