//
//  고려대학교.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 고려대학교: UniversityType {
  
  var name: String {
    return "고려대학교"
  }
  
  var categories: [Category] {
    return [
      ("NG", "일반공지"),
      ("E", "학사공지"),
      ("J", "장학공지")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(categoryQueryForPost(category))\(linkQueryForPost(link))") else {
      return nil
    }
    return url
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let titles = document.xpath("//div[@class='summary']//a[@class='sbj']")
        let rows = document.xpath("//div[@class='summary']//li")
        let links = document.xpath("//div[@class='summary']//a/@href")
        links.enumerated().forEach { index, element in
          let dateIndex = index * 3 + 2
          let number = 1
          let title = titles[index].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed.filter { Int($0.description) != nil } ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 고려대학교 {
  
  var baseURL: String {
    return "http://www.korea.ac.kr/cop/portalBoard/"
  }
  
  var commonQueries: String {
    return "portalBoardList.do?siteId=university"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&type=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&findType=SUBJECT&findWord=\(text.percentEncoding)"
  }
}

private extension 고려대학교 {
  
  var commonQueriesForPost: String {
    return "portalBoardView.do?siteId=university"
  }
  
  func categoryQueryForPost(_ category: Category) -> String {
    return "&type=\(category.identifier)"
  }
  
  func linkQueryForPost(_ articleId: String) -> String {
    return "&articleId=\(articleId)"
  }
}
