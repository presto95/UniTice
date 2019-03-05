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
  
  let initialState: Post
  
  init(post: Post) {
    self.initialState = post
  }
}
