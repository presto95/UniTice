//
//  MainContainerViewReactor.swift
//  UniTice
//
//  Created by Presto on 02/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class MainContainerViewReactor: Reactor {

  enum Action {

    case setting
    
    case search
    
    case bookmark
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    
  }
}
