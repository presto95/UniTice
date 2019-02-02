//
//  Bookmark.swift
//  UniTice
//
//  Created by Presto on 10/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import RealmSwift

@objcMembers
final class Bookmark: Object {
  
  dynamic var index: Int = 0
  
  dynamic var category: String = ""
  
  dynamic var title: String = ""
  
  dynamic var date: String = ""
  
  dynamic var link: String = ""
  
  func incrementIndex() -> Int {
    return (try! Realm().objects(Bookmark.self).max(ofProperty: "index") as Int? ?? 0) + 1
  }
}
