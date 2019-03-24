//
//  MainContainerViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation
import StoreKit

import ReactorKit
import RxSwift

/// The `Reactor` for `MainContainerViewController`.
final class MainContainerViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the view is loaded in memory.
    case viewDidLoad
    
    /// The action that the view will appear.
    case viewWillAppear
    
    /// The action that the view is appeared.
    case viewDidAppear
    
    /// The action that the user taps the setting bar button item.
    case setting
    
    /// The action that the user taps the search bar button item.
    case search
    
    /// The action that the user taps the bookmark bar button item.
    case bookmark
  }
  
  enum Mutation {
    
    /// The mutation to reload view.
    case reloadView(Bool)
    
    /// The mutation to register the user notification.
    case registerUserNotification(Bool)
    
    /// The mutation to set up whether the setting scene is presented.
    case setting(Bool)
    
    /// The mutation to set up whether the search scene is presented.
    case search(Bool)
    
    /// The mutation to set up whether the bookmark scene is presented.
    case bookmark(Bool)
  }
  
  struct State {
    
    /// The boolean value indicating whether the view is reloaded.
    var isViewReloaded: Bool = false
    
    /// The boolean value indicating whether the user notification has registered.
    var isUserNotificationRegistered: Bool?
    
    /// The boolean value indicating whether the setting bar button item is tapped.
    var isSettingButtonTapped: Bool = false
    
    /// The boolean value indicating whether the search bar button item is tapped.
    var isSearchButtonTapped: Bool = false
    
    /// The boolean value indicating whether the bookmark bar button item is tapped.
    var isBookmarkButtonTapped: Bool = false
  }
  
  let initialState: State = .init()
  
  /// The user notification service.
  private let userNotificationService: UserNotificationServiceType
  
  init(userNotificationService: UserNotificationServiceType = UserNotificationService.shared) {
    self.userNotificationService = userNotificationService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return userNotificationService
        .registerUserNotification()
        .map { Mutation.registerUserNotification($0) }
    case .viewWillAppear:
      return Observable.concat([
        Observable.just(Mutation.reloadView(true)),
        Observable.just(Mutation.reloadView(false))
        ])
    case .viewDidAppear:
      return presentRatingAlertInRandom()
    case .setting:
      return Observable.concat([
        Observable.just(Mutation.setting(true)),
        Observable.just(Mutation.setting(false))
        ])
    case .search:
      return Observable.concat([
        Observable.just(Mutation.search(true)),
        Observable.just(Mutation.search(false))
        ])
    case .bookmark:
      return Observable.concat([
        Observable.just(Mutation.bookmark(true)),
        Observable.just(Mutation.bookmark(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .reloadView(isReloaded):
      state.isViewReloaded = isReloaded
    case let .registerUserNotification(isRegistered):
      state.isUserNotificationRegistered = isRegistered
    case let .setting(isTapped):
      state.isSettingButtonTapped = isTapped
    case let .search(isTapped):
      state.isSearchButtonTapped = isTapped
    case let .bookmark(isTapped):
      state.isBookmarkButtonTapped = isTapped
    }
    return state
  }
}

// MARK: - Private Method

private extension MainContainerViewReactor {
  
  func presentRatingAlertInRandom() -> Observable<Mutation> {
    if Int.random(in: 1...10) == 1 {
      SKStoreReviewController.requestReview()
    }
    return Observable.empty()
  }
}
