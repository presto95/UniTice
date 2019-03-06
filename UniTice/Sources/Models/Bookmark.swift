//
//  Bookmark.swift
//  UniTice
//
//  Created by Presto on 10/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import RealmSwift

/// 북마크 Realm 모델.
@objcMembers
final class Bookmark: Object {
  
  /// 인덱스.
  dynamic var index: Int = 0
  
  /// 카테고리.
  dynamic var category: String = ""
  
  /// 제목.
  dynamic var title: String = ""
  
  /// 날짜.
  dynamic var date: String = ""
  
  /// 게시물 링크.
  dynamic var link: String = ""
}

extension Bookmark {
  
  /// Auot Increment 인덱스.
  static var uniqueID: Int {
    return (try! Realm().objects(Bookmark.self).max(ofProperty: "index") as Int? ?? 0) + 1
  }
}
