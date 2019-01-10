//
//  UniversityModel.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

protocol UniversityScrappable {
    
    /// 대학별 카테고리를 정의하기 위한 타입 별칭 정의. 식별자와 디스크립션을 갖는 튜플 형태.
    typealias Category = (identifier: String, description: String)
    
    /// 대학 이름.
    var name: String { get }
    
    /// 카테고리.
    var categories: [Category] { get }
    
    /// 파싱할 URL.
    ///
    /// - Parameters:
    ///   - category: 카테고리
    ///   - page: 페이지
    ///   - text: 검색 키워드
    /// - Returns: 파싱할 URL
    /// - Throws: URL 형식에 맞지 않는 경우 에러 던짐.
    func pageURL(inCategory category: Category, inPage page: Int, searchText text: String) throws -> URL
    
    /// 게시물 URL.
    ///
    /// - Parameters:
    ///   - category: 카테고리
    ///   - link: 파싱 결과에 따른 게시물 URI
    /// - Returns: 게시물 URL
    /// - Throws: URL 형식에 맞지 않는 경우 에러 던짐.
    func postURL(inCategory category: Category, uri link: String) throws -> URL
    
    /// 게시물 요청.
    ///
    /// - Parameters:
    ///   - category: 카테고리
    ///   - page: 페이지
    ///   - text: 검색 키워드. 기본값 `""`
    ///   - completion: 요청 후 컴플리션 핸들러
    func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void))
    
    /// Base URL.
    var baseURL: String { get }
    
    /// 불필요한 쿼리 문자열.
    var commonQueries: String { get }
    
    /// 카테고리 쿼리 문자열.
    ///
    /// - Parameter category: 카테고리
    /// - Returns: 카테고리 쿼리 문자열
    func categoryQuery(_ category: Category) -> String
    
    /// 페이지 쿼리 문자열.
    ///
    /// - Parameter page: 페이지
    /// - Returns: 페이지 쿼리 문자열
    func pageQuery(_ page: Int) -> String
    
    /// 검색 쿼리 문자열.
    ///
    /// - Parameter text: 검색 키워드
    /// - Returns: 검색 쿼리 문자열
    func searchQuery(_ text: String) -> String
}

extension UniversityScrappable {
    
    /// 파싱할 URL 초기 구현. `Base URL` - `불필요한 쿼리 스트링` - `카테고리 쿼리 스트링` - `페이지 쿼리 스트링` - `검색 쿼리 스트링`으로 구성됨.
    func pageURL(inCategory category: Category, inPage page: Int, searchText text: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueries)\(categoryQuery(category))\(pageQuery(page))\(searchQuery(text))") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    /// 게시물 URL 초기 구현. `Base URL` - `게시물 링크`로 구성됨.
    func postURL(inCategory category: Self.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(link.percentEncoding)") else {
            throw UniversityError.invalidURLError
        }
        print(url.absoluteString)
        return url
    }
}
