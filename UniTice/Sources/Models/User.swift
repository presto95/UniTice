//
//  User.swift
//  UniTice
//
//  Created by Presto on 25/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import RealmSwift

@objcMembers
final class User: Object {
  
  dynamic var university: String = ""
  
  dynamic var keywords: List<String> = List<String>()
  
  dynamic var bookmarks: List<Bookmark> = List<Bookmark>()
}
