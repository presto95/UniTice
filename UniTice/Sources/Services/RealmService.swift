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

/// Realm 서비스 타입.
protocol RealmServiceType: class {
  
  /// Realm 인스턴스.
  var realm: Realm { get }
  
  /// 사용자 추가.
  @discardableResult
  func addUser(_ user: User) -> Observable<User>
  
  /// 북마크 추가.
  @discardableResult
  func addBookmark(_ post: Post) -> Observable<Bookmark>
  
  /// 키워드 추가.
  @discardableResult
  func addKeyword(_ keyword: String?) -> Observable<String?>
  
  /// 사용자 가져오기.
  func fetchUser() -> Observable<User>
  
  /// 모든 북마크 가져오기.
  func fetchBookmarks() -> Observable<[Bookmark]>
  
  /// 모든 키워드 가져오기.
  func fetchKeywords() -> Observable<[String]>
  
  /// 대학교 가져오기.
  func fetchUniversity() -> Observable<University>
  
  /// 대학교 갱신하기.
  @discardableResult
  func updateUniversity(_ university: University) -> Observable<University>
  
  /// 북마크 삭제하기.
  @discardableResult
  func removeBookmark(at index: Int) -> Observable<Void>
  
  /// 모든 북마크 삭제하기.
  @discardableResult
  func removeAllBookmarks() -> Observable<Void>
  
  /// 키워드 삭제하기.
  @discardableResult
  func removeKeyword(at index: Int) -> Observable<Void>
  
  /// 모든 키워드 삭제하기.
  @discardableResult
  func removeAllKeywords() -> Observable<Void>
}

/// Realm 서비스.
final class RealmService: RealmServiceType {
  
  /// RealmService Singleton Object.
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
