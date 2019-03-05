//
//  SettingTableViewReactor.swift
//  UniTice
//
//  Created by Presto on 05/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

final class SettingTableViewReactor: Reactor {
  
  //typealias SettingSectionModel = SectionModel<Void, String>
  
  enum Action {
    
    case fetchNotificationStatus(Bool)
    
    case toggleUpperPostFoldSwitch
    
    case setNotificationSwitch(Bool)
  }
  
  enum Mutation {
    
    case setNotificationStatus(Bool)
    
    case toggleUpperPostFoldSwitch
  }
  
  struct State {
    
    var isUpperPostFolded: Bool
    
    var isNotificationGranted: Bool
  }
  
  let persistenceService: PersistenceServiceType
  
  let initialState: State
  
  init(isNotificationGranted: Bool, isUpperPostFolded: Bool) {
    initialState = State(isUpperPostFolded: isUpperPostFolded,
                         isNotificationGranted: isNotificationGranted)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .fetchNotificationStatus(isGranted):
      return Observable.just(Mutation.setNotificationStatus(isGranted))
    case .toggleUpperPostFoldSwitch:
      return Observable.just(Mutation.toggleUpperPostFoldSwitch)
    case let .setNotificationSwitch(isGranted):
      return Observable.just(Mutation.setNotificationStatus(isGranted))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setNotificationStatus(isGranted):
      state.isNotificationGranted = isGranted
    case .toggleUpperPostFoldSwitch:
      state.isUpperPostFolded.toggle()
    }
    return state
  }
}
