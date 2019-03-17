//
//  PostCellReactor.swift
//  UniTice
//
//  Created by Presto on 03/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

/// The `Reactor` for `PostCell`.
final class PostCellReactor: Reactor {
  
  typealias Action = NoAction
  
  typealias Mutation = NoMutation
  
  struct State {
    
    /// The section data to present.
    var sectionData: UTSectionData
    
    /// The keywords.
    var keywords: [String]
  }
  
  let initialState: State
  
  init(sectionData: UTSectionData, keywords: [String]) {
    initialState = .init(sectionData: sectionData, keywords: keywords)
  }
}
