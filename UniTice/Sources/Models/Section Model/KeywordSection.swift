//
//  KeywordSection.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxDataSources

struct KeywordSectionData {
  
  var keyword: String
}

struct KeywordSection {
  
  var items: [Item]
}

extension KeywordSection: SectionModelType {
  
  typealias Item = KeywordSectionData
  
  init(original: KeywordSection, items: [Item]) {
    self = original
    self.items = items
  }
}
