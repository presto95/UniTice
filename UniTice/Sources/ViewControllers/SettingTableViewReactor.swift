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

/// 설정 테이블 뷰 리액터.
final class SettingTableViewReactor: Reactor {
  
  enum Action {
    
    /// 알림 권한 상태 가져오기.
    case fetchNotificationStatus(Bool)
    
    /// 상단 고정 게시물 스위치 토글.
    case toggleUpperPostFoldSwitch
  }
  
  enum Mutation {
    
    /// 알림 권한 상태 설정.
    case setNotificationStatus(Bool)
    
    /// 상단 고정 게시물 스위치 토글.
    case toggleUpperPostFoldSwitch
  }
  
  struct State {
    
    /// 섹션 모델.
    var sections: [SettingTableViewSection] = [
      SettingTableViewSection(footer: nil, items: ["상단 고정 게시물 펼치기"]),
      SettingTableViewSection(footer: nil, items: ["학교 변경", "키워드 설정", "알림 설정"]),
      SettingTableViewSection(footer: nil, items: ["문의하기", "앱 평가하기"])
    ]
    
    /// 상단 고정 게시물이 펼쳐져 있는 상태인가.
    var isUpperPostFolded: Bool
    
    /// 알림 권한이 허용된 상태인가.
    var isNotificationGranted: Bool
    
    init(isUpperPostFolded: Bool, isNotificationGranted: Bool) {
      self.isUpperPostFolded = isUpperPostFolded
      self.isNotificationGranted = isNotificationGranted
    }
  }
  
  /// 초기 상태.
  let initialState: State
  
  /// 데이터 보존 서비스.
  let persistenceService: PersistenceServiceType
  
  init(isNotificationGranted: Bool,
       isUpperPostFolded: Bool,
       persistenceService: PersistenceServiceType = PersistenceService.shared) {
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
