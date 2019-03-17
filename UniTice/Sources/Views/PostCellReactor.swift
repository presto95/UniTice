//
//  PostCellReactor.swift
//  UniTice
//
//  Created by Presto on 03/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class PostCellReactor: Reactor {
  
  typealias Action = NoAction
  
  typealias Mutation = NoMutation
  
  struct State {
    
    var sectionData: UTSectionData
    
    var keywords: [String]
  }
  
  let initialState: State
  
  init(sectionData: UTSectionData, keywords: [String]) {
    initialState = State(sectionData: sectionData, keywords: keywords)
  }
}
