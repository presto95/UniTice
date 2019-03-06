//
//  UTSection.swift
//  UniTice
//
//  Created by Presto on 06/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxDataSources

/// UniTice 섹션 데이터.
struct UTSectionData {
  
  /// 게시물 제목.
  var title: String
  
  /// 게시물 날짜.
  var date: String
  
  /// 게시물 링크.
  var link: String
}

/// UniTice 섹션.
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
