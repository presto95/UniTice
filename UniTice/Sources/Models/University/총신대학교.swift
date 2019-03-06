//
//  총신대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 총신대학교: UniversityType {
  
  var name: String {
    return "총신대학교"
  }
  
  var categories: [Category] {
    return [
      ("54", "대학공지사항"),
      ("55", "신대원공지사항"),
      ("56", "대학원공지사항")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//tr//td[@class='l']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 6
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 3
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 총신대학교 {
  
  var baseURL: String {
    return "http://www.chongshin.ac.kr/mbs/csu/jsp/board/"
  }
  
  var commonQueries: String {
    return "list.jsp?column=TITLE&id=csu_010501000000"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&boardId=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&spage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoding)"
  }
}
