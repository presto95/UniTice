//
//  UniversityModel.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift
import Kanna

/// 대학교 프로토콜.
protocol UniversityType {
  
  /// HTML 파싱 매니저 타입.
  var htmlParseManager: HTMLParseManagerType { get }
  
  /// 대학 이름.
  var name: String { get }
  
  /// 카테고리.
  var categories: [Category] { get }
  
  /// 파싱할 페이지 URL.
  func pageURL(inCategory category: Category, inPage page: Int, searchText text: String) -> URL?
  
  /// 게시물 URL.
  func postURL(inCategory category: Category, uri link: String) -> URL?
  
  /// 게시물 요청.
  func requestPosts(inCategory category: Category,
                    inPage page: Int,
                    searchText text: String) -> Observable<[Post]>
  
  /// Base URL.
  var baseURL: String { get }
  
  /// 불필요한 쿼리 문자열.
  var commonQueries: String { get }
  
  /// 카테고리 쿼리 문자열.
  func categoryQuery(_ category: Category) -> String
  
  /// 페이지 쿼리 문자열.
  func pageQuery(_ page: Int) -> String
  
  /// 검색 쿼리 문자열.
  func searchQuery(_ text: String) -> String
}

// MARK: - UniversityType 프로토콜 초기 구현

extension UniversityType {
  
  var htmlParseManager: HTMLParseManagerType {
    return HTMLParseManager.shared
  }
  
  /// 파싱할 URL 초기 구현.
  ///
  /// `Base URL` - `불필요한 쿼리 스트링` - `카테고리 쿼리 스트링` - `페이지 쿼리 스트링` - `검색 쿼리 스트링`으로 구성된다.
  func pageURL(inCategory category: Category, inPage page: Int, searchText text: String) -> URL? {
    let urlString = baseURL
      .appending(commonQueries)
      .appending(categoryQuery(category))
      .appending(pageQuery(page))
      .appending(searchQuery(text))
    return URL(string: urlString)
  }
  
  /// 게시물 URL 초기 구현.
  ///
  /// `Base URL` - `게시물 링크`로 구성됨.
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    return URL(string: "\(baseURL)\(link.percentEncoded)")
  }
}
