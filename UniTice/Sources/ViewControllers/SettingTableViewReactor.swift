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

struct SettingTableViewSection {
  
  var footer: String?
  
  var items: [Item]
}

extension SettingTableViewSection: SectionModelType {
  
  typealias Item = String
  
  init(original: SettingTableViewSection, items: [Item]) {
    self = original
    self.items = items
  }
}

final class SettingTableViewReactor: Reactor {
  
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
    
    var sections: [SettingTableViewSection] = [
      SettingTableViewSection(footer: nil, items: ["상단 고정 게시물 펼치기"]),
      SettingTableViewSection(footer: nil, items: ["학교 변경", "키워드 설정", "알림 설정"]),
      SettingTableViewSection(footer: nil, items: ["문의하기", "앱 평가하기"])
    ]
    
    var isUpperPostFolded: Bool
    
    var isNotificationGranted: Bool
    
    init(isUpperPostFolded: Bool, isNotificationGranted: Bool) {
      self.isUpperPostFolded = isUpperPostFolded
      self.isNotificationGranted = isNotificationGranted
    }
  }
  
  let persistenceService: PersistenceServiceType
  
  let initialState: State
  
  init(persistenceService: PersistenceServiceType,
       isNotificationGranted: Bool,
       isUpperPostFolded: Bool) {
    self.persistenceService = persistenceService
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
      state.sections[1].footer = isGranted ? "알림이 활성화되어 있습니다." : "알림이 비활성화되어 있습니다."
    case .toggleUpperPostFoldSwitch:
      state.isUpperPostFolded.toggle()
      state.sections[0].footer
        = state.isUpperPostFolded ? "상단 고정 게시물이 펼쳐진 상태입니다." : "상단 고정 게시물이 접혀진 상태입니다."
      persistenceService.isUpperPostFolded = state.isUpperPostFolded
    }
    return state
  }
}
