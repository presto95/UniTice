//
//  RealmService.swift
//  UniTice
//
//  Created by Presto on 05/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RealmSwift
import RxSwift

/// The `protocol` that defines the realm service.
protocol RealmServiceType: class {
  
  /// The `Realm` instance.
  var realm: Realm { get }
  
  /// Adds the `user`.
  @discardableResult
  func addUser(_ user: User) -> Observable<User>
  
  /// Adds the `post` to bookmark.
  @discardableResult
  func addBookmark(_ post: Post) -> Observable<Bookmark>
  
  /// Adds the `keyword`.
  @discardableResult
  func addKeyword(_ keyword: String?) -> Observable<String?>
  
  /// Fetches user.
  func fetchUser() -> Observable<User>
  
  /// Fetches all bookmarks.
  func fetchBookmarks() -> Observable<[Bookmark]>
  
  /// Fetches all keywords.
  func fetchKeywords() -> Observable<[String]>
  
  /// Fetches the university.
  func fetchUniversity() -> Observable<University>
  
  /// Updates the `university`.
  @discardableResult
  func updateUniversity(_ university: University) -> Observable<University>
  
  /// Removes the `index`th bookmark.
  @discardableResult
  func removeBookmark(at index: Int) -> Observable<Void>
  
  /// Removes all bookmarks.
  @discardableResult
  func removeAllBookmarks() -> Observable<Void>
  
  /// Removes the `index`th keyword.
  @discardableResult
  func removeKeyword(at index: Int) -> Observable<Void>
  
  /// Removes all keywords.
  @discardableResult
  func removeAllKeywords() -> Observable<Void>
}

/// The `class` that defines the realm service.
final class RealmService: RealmServiceType {
  
  /// The singleton object of `RealmService`.
  static let shared = RealmService()
  
  var realm: Realm {
    return try! Realm()
  }
  
  func addUser(_ user: User) -> Observable<User> {
    try! realm.write {
      realm.add(user)
    }
    return Observable.just(user)
  }
  
  func addBookmark(_ post: Post) -> Observable<Bookmark> {
    return fetchUser().flatMap { user -> Observable<Bookmark> in
      let bookmark = Bookmark()
      bookmark.index = Bookmark.uniqueID
      bookmark.title = post.title
      bookmark.date = post.date
      bookmark.link = post.link
      let isRedundant = user.bookmarks.map { $0.link }.contains(post.link)
      if !isRedundant {
        try self.realm.write {
          user.bookmarks.insert(bookmark, at: 0)
        }
        return Observable.just(bookmark)
      }
      return .empty()
    }
  }
  
  func addKeyword(_ keyword: String?) -> Observable<String?> {
    return fetchUser().flatMap { [weak self] user -> Observable<String?> in
      guard let self = self else { return .empty() }
      guard let keyword = keyword else { return .empty() }
      let isRedundant = user.keywords.contains(keyword)
      if !isRedundant {
        try self.realm.write {
          user.keywords.insert(keyword, at: 0)
        }
        return Observable.just(keyword)
      }
      return .empty()
    }
  }
  
  func fetchUser() -> Observable<User> {
    if let user = realm.objects(User.self).last {
      return Observable.just(user)
    }
    return Observable.empty()
  }
  
  func fetchBookmarks() -> Observable<[Bookmark]> {
    return fetchUser().flatMap { user in
      return Observable.just(Array(user.bookmarks))
    }
  }
  
  func fetchKeywords() -> Observable<[String]> {
    return fetchUser().flatMap { user in
      return Observable.just(Array(user.keywords))
    }
  }
  
  func fetchUniversity() -> Observable<University> {
    return fetchUser().flatMap { Observable.just($0.university) }
      .map { University(rawValue: $0) ?? .kaist }
  }
  
  func updateUniversity(_ university: University) -> Observable<University> {
    return fetchUser().flatMap { [weak self] user -> Observable<University> in
      guard let self = self else { return .empty() }
      try! self.realm.write {
        user.university = university.rawValue
      }
      return .just(university)
    }
  }
  
  func removeBookmark(at index: Int) -> Observable<Void> {
    return fetchUser().flatMap { [weak self] user -> Observable<Void> in
      guard let self = self else { return .empty() }
      try! self.realm.write {
        user.bookmarks.remove(at: index)
      }
      return .just(Void())
    }
  }
  
  func removeAllBookmarks() -> Observable<Void> {
    return fetchUser().flatMap { [weak self] user -> Observable<Void> in
      guard let self = self else { return .empty() }
      try! self.realm.write {
        user.bookmarks.removeAll()
      }
      return .just(Void())
    }
  }
  
  func removeKeyword(at index: Int) -> Observable<Void> {
    return fetchUser().flatMap { [weak self] user -> Observable<Void> in
      guard let self = self else { return .empty() }
      try! self.realm.write {
        user.keywords.remove(at: index)
      }
      return .just(Void())
    }
  }
  
  func removeAllKeywords() -> Observable<Void> {
    return fetchUser().flatMap { [weak self] user -> Observable<Void> in
      guard let self = self else { return .empty() }
      try! self.realm.write {
        user.keywords.removeAll()
      }
      return .just(Void())
    }
  }
}
