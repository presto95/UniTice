//
//  User.swift
//  UniTice
//
//  Created by Presto on 25/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import RealmSwift

/// 사용자 Realm 모델.
@objcMembers
final class User: Object {
  
  /// 사용자 대학교.
  dynamic var university: String = ""
  
  /// 사용자 키워드.
  dynamic var keywords: List<String> = List<String>()
  
  /// 사용자 북마크.
  dynamic var bookmarks: List<Bookmark> = List<Bookmark>()
}
