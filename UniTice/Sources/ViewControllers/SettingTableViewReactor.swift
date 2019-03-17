//
//  SettingTableViewReactor.swift
//  UniTice
//
//  Created by Presto on 05/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` of `SettingTableViewController`.
final class SettingTableViewReactor: Reactor {
  
  enum Action {
    
    case viewDidLoad
    
    /// The action that the user fetches user notification status.
    case fetchNotificationStatus(Bool)
    
    /// The action that the user toggles switch describing the upper post folding status.
    case toggleUpperPostFoldingSwitch
  }
  
  enum Mutation {
    
    /// The mutation that setting initial footer string value.
    case setInitialFooter(Bool, Bool)
    
    /// The mutation that setting notification status.
    case setNotificationStatus(Bool)
    
    /// The mutation that toggling upper post folding switch control.
    case setUpperPostFoldingStatus
  }
  
  struct State {
    
    /// The section models.
    var sections: [SettingTableViewSection] = [
      .init(footer: nil, items: ["상단 고정 게시물 접기"]),
      .init(footer: nil, items: ["학교 변경", "키워드 설정", "알림 설정"]),
      .init(footer: nil, items: ["문의하기", "앱 평가하기"]),
      .init(footer: nil, items: ["오픈 소스 라이센스"])
    ]
    
    /// The boolean value indicating whether the upper post is folded.
    var isUpperPostFolded: Bool = false
    
    /// The boolean value indicating whether the user notification permission is granted.
    var isNotificationGranted: Bool = false
  }
  
  let initialState: State = .init()
  
  /// The realm service.
  private let realmService: RealmServiceType
  
  /// The user defaults service.
  private let userDefaultsService: UserDefaultsServiceType
  
  /// The user notification service.
  private let userNotificationService: UserNotificationServiceType
  
  init(realmService: RealmServiceType = RealmService.shared,
       userDefaultsService: UserDefaultsServiceType = UserDefaultsService.shared,
       userNotificationService: UserNotificationServiceType = UserNotificationService.shared) {
    self.realmService = realmService
    self.userDefaultsService = userDefaultsService
    self.userNotificationService = userNotificationService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return setInitialState()
    case let .fetchNotificationStatus(isGranted):
      return Observable.just(Mutation.setNotificationStatus(isGranted))
    case .toggleUpperPostFoldingSwitch:
      return Observable.just(Mutation.setUpperPostFoldingStatus)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setInitialFooter(isUpperPostFolded, isNotifictionGranted):
      state.isUpperPostFolded = isUpperPostFolded
      state.isNotificationGranted = isNotifictionGranted
      setSections(state: &state,
                  isUpperPostFolded: isUpperPostFolded,
                  isNotificationGranted: isNotifictionGranted)
    case let .setNotificationStatus(isGranted):
      state.isNotificationGranted = isGranted
      setSections(state: &state,
                  isUpperPostFolded: currentState.isUpperPostFolded,
                  isNotificationGranted: isGranted)
    case .setUpperPostFoldingStatus:
      state.isUpperPostFolded.toggle()
      setSections(state: &state,
                  isUpperPostFolded: state.isUpperPostFolded,
                  isNotificationGranted: currentState.isNotificationGranted)
      userDefaultsService.isUpperPostFolded = state.isUpperPostFolded
    }
    return state
  }
}

// MARK: - Private Method

private extension SettingTableViewReactor {
  
  func setInitialState() -> Observable<Mutation> {
    let isUpperPostFolded = Observable.just(userDefaultsService.isUpperPostFolded)
    let isNotificatinGranted = userNotificationService.requestUserNotificationIsAuthorized()
    return Observable
      .combineLatest(isUpperPostFolded, isNotificatinGranted) { ($0, $1) }
      .map { Mutation.setInitialFooter($0.0, $0.1) }
  }
  
  func setSections(state: inout State, isUpperPostFolded: Bool, isNotificationGranted: Bool) {
    let upperPostFooter = isUpperPostFolded
      ? "상단 고정 게시물이 접혀진 상태입니다."
      : "상단 고정 게시물이 펼쳐진 상태입니다."
    let notificationFooter = isNotificationGranted
      ? "알림이 활성화되어 있습니다."
      : "알림이 비활성화되어 있습니다."
    state.sections = [
      .init(footer: upperPostFooter, items: ["상단 고정 게시물 접기"]),
      .init(footer: notificationFooter, items: ["학교 변경", "키워드 설정", "알림 설정"]),
      .init(footer: nil, items: ["문의하기", "앱 평가하기"]),
      .init(footer: nil, items: ["오픈 소스 라이센스"])
    ]
  }
}
