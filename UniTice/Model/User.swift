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
  
  static func addUser(_ user: User) {
    guard User.fetch() == nil else { return }
    let realm = try! Realm()
    let object = User()
    object.university = user.university
    object.keywords = user.keywords
    object.bookmarks = user.bookmarks
    try! realm.write {
      realm.add(object)
    }
  }
  
  static func updateUniversity(_ university: String) {
    guard let user = User.fetch() else { return }
    try! Realm().write {
      user.university = university
    }
  }
  
  static func insertBookmark(_ post: Post) {
    guard let user = User.fetch() else { return }
    let bookmark = Bookmark()
    bookmark.index = bookmark.uniqueID
    bookmark.title = post.title
    bookmark.date = post.date
    bookmark.link = post.link
    let filteredCount = user.bookmarks.filter { $0.link == post.link }.count
    if filteredCount == 0 {
      try! Realm().write {
        user.bookmarks.insert(bookmark, at: 0)
      }
    }
  }
  
  static func removeBookmark(_ bookmark: Bookmark) {
    guard let user = User.fetch() else { return }
    try! Realm().write {
      if let bookmarkIndex = user.bookmarks.index(of: bookmark) {
        user.bookmarks.remove(at: bookmarkIndex)
      }
    }
  }
  
  static func removeBookmarksAll() {
    guard let user = User.fetch() else { return }
    try! Realm().write {
      user.bookmarks.removeAll()
    }
  }
  
  static func insertKeyword(_ keyword: String, _ completion: (Bool) -> Void) {
    guard let user = User.fetch() else { return }
    let hasDuplicated = !Array(user.keywords.filter { $0 == keyword }).isEmpty
    if !hasDuplicated {
      try! Realm().write {
        user.keywords.insert(keyword, at: 0)
      }
    }
    completion(hasDuplicated)
  }
  
  static func removeKeyword(_ keyword: String) {
    guard let user = User.fetch() else { return }
    try! Realm().write {
      if let keywordIndex = user.keywords.index(of: keyword) {
        user.keywords.remove(at: keywordIndex)
      }
    }
  }
  
  static func removeKeywordsAll() {
    guard let user = User.fetch() else { return }
    try! Realm().write {
      user.keywords.removeAll()
    }
  }
  
  static func fetch() -> User? {
    if let user = try! Realm().objects(User.self).last {
      return user
    }
    return nil
  }
}
