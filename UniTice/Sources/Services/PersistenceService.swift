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
protocol PersistenceServiceType: class {
  
  var realm: Realm { get }
  
  /// 사용자 추가.
  func addUser(_ user: User) -> Observable<Void>
  
  /// 북마크 추가.
  func addBookmark(_ post: Post) -> Observable<Void>
  
  /// 키워드 추가.
  func addKeyword(_ keyword: String) -> Observable<String>
  
  /// 사용자 가져오기.
  func fetchUser() -> Observable<User>
  
  /// 모든 북마크 가져오기.
  func fetchBookmarks() -> Observable<[Bookmark]>
  
  /// 모든 키워드 가져오기.
  func fetchKeywords() -> Observable<[String]>
  
  /// 대학교 갱신하기.
  func updateUniversity(_ university: University) -> Observable<University>
  
  /// 북마크 삭제하기.
  func removeBookmark(_ bookmark: Bookmark) -> Observable<Void>
  
  /// 모든 북마크 삭제하기.
  func removeAllBookmarks() -> Observable<Void>
  
  /// 키워드 삭제하기.
  func removeKeyword(_ keyword: String) -> Observable<Void>
  
  /// 모든 키워드 삭제하기.
  func removeAllKeywords() -> Observable<Void>
  
  var isUpperPostFolded: Bool { get }
}

final class PersistenceService: PersistenceServiceType {
  
  var realm: Realm {
    return try! Realm()
  }
  
  func addUser(_ user: User) -> Observable<Void> {
    let newUser = user
    return fetchUser().flatMap { _ in .empty() }
      .ifEmpty(switchTo: Observable<Void>.create({ [weak self] observer in
        guard let self = self else { return Disposables.create() }
        do {
          try self.realm.write {
            self.realm.add(newUser)
            observer.onNext(Void())
            observer.onCompleted()
          }
        } catch {
          observer.onError(error)
        }
        return Disposables.create()
      }))
  }
  
  func addBookmark(_ post: Post) -> Observable<Void> {
    return fetchUser().flatMap { user -> Observable<Void> in
      let bookmark = Bookmark()
      bookmark.index = Bookmark.uniqueID
      bookmark.title = post.title
      bookmark.date = post.date
      bookmark.link = post.link
      let isRedundant = user.bookmarks.filter({ $0.link == post.link }).isEmpty
      if isRedundant {
        
      }
      
    }
  }
  
  func addKeyword(_ keyword: String) -> Observable<String> {
    
  }
  
  func fetchUser() -> Observable<User> {
    if let user = realm.objects(User.self).last {
      return Observable.just(user)
    }
    return Observable.empty()
  }
  
  func fetchBookmarks() -> Observable<[Bookmark]> {
    
  }
  
  func fetchKeywords() -> Observable<[String]> {
    
  }
  
  func updateUniversity(_ university: University) -> Observable<University> {
    
  }
  
  func removeBookmark(_ bookmark: Bookmark) -> Observable<Void> {
    
  }
  
  func removeAllBookmarks() -> Observable<Void> {
    
  }
  
  func removeKeyword(_ keyword: String) -> Observable<Void> {
    
  }
  
  func removeAllKeywords() -> Observable<Void> {
    
  }
  
  var isUpperPostFolded: Bool {
    return UserDefaults.standard.value(forKey: "fold") as? Bool ?? false
  }
}
