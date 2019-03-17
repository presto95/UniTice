//
//  KeywordSection.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxDataSources

struct KeywordSettingSection {
  
  var footer: String
  
  var items: [Item]
}

extension KeywordSettingSection: SectionModelType {
  
  typealias Item = String

  init(original: KeywordSettingSection, items: [Item]) {
    self = original
    self.items = items
  }
}
