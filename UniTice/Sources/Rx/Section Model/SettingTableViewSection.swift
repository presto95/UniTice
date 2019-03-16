//
//  SettingTableViewSection.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxDataSources

struct SettingTableViewSection {
  
  var footer: String?
  
  var items: [Item]
}

extension SettingTableViewSection: SectionModelType {
  
  typealias Item = String
  
  init(original: SettingTableViewSection, items: [Item]) {
    self = original
    self.items = items
  }
}
