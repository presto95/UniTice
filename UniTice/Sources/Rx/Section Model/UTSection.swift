//
//  UTSection.swift
//  UniTice
//
//  Created by Presto on 06/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxDataSources

struct UTSectionData {
  
  var title: String
  
  var date: String
  
  var link: String
}

struct UTSection {
  
  var items: [Item]
}

extension UTSection: SectionModelType {
  
  typealias Item = UTSectionData
  
  init(original: UTSection, items: [Item]) {
    self = original
    self.items = items
  }
}
