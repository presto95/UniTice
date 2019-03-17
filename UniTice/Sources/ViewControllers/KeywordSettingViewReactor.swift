//
//  KeywordSettingViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `KeywordSettingViewController`.
final class KeywordSettingViewReactor: Reactor {
  
  enum Action {
    
    /// The action that the view is loaded in memory.
    case viewDidLoad
    
    /// The action that the user taps the register bar button item.
    case register
    
    /// The action that the user taps the confirm button in the alert controller.
    case alertConfirm(String?)
    
    /// The action that the user taps the cancel button in the alert controller.
    case alertCancel
    
    /// The action that the user provokes deleting the keyword at `index`.
    case deleteKeyword(index: Int)
  }
  
  enum Mutation {
    
    /// The mutation to present the alert controller.
    case presentAlert
    
    /// The mutation to dismiss the alert controller.
    case dismissAlert
    
    /// The mutation to set keywords.
    case setKeywords([String])
    
    /// The mutation to add the keyword.
    case addKeyword(String?)
    
    /// The mutation to delete the keyword at `index`.
    case deleteKeyword(index: Int)
  }
  
  struct State {
    
    /// The keyword string values.
    var keywords: [String] = []
    
    /// The boolean value indicating whether the alert controller is presenting.
    var isAlertPresenting: Bool = false
  }
  
  let initialState: State = .init()
  
  /// The realm service.
  private let realmService: RealmServiceType
  
  init(realmService: RealmServiceType = RealmService.shared) {
    self.realmService = realmService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return realmService.fetchKeywords().map { Mutation.setKeywords($0) }
    case .register:
      return Observable.just(.presentAlert)
    case let .alertConfirm(keyword):
      return Observable.concat([
        realmService.addKeyword(keyword).map { Mutation.addKeyword($0) },
        Observable.just(Mutation.dismissAlert)
        ])
    case .alertCancel:
      return Observable.just(.dismissAlert)
    case let .deleteKeyword(index):
      return realmService.removeKeyword(at: index).map { Mutation.deleteKeyword(index: index) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .presentAlert:
      state.isAlertPresenting = true
    case .dismissAlert:
      state.isAlertPresenting = false
    case let .setKeywords(keywords):
      state.keywords = keywords
    case let .addKeyword(keyword):
      state.keywords.insert(keyword ?? "", at: 0)
    case let .deleteKeyword(index):
      state.keywords.remove(at: index)
    }
    return state
  }
}
