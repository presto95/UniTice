//
//  KeywordRegisterSection.swift
//  UniTice
//
//  Created by Presto on 17/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxDataSources

struct KeywordRegisterSection {
  
  var items: [Item]
}

extension KeywordRegisterSection: SectionModelType {
  
  typealias Item = String
  
  init(original: KeywordRegisterSection, items: [Item]) {
    self = original
    self.items = items
  }
}
