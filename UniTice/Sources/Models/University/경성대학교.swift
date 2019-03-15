//
//  경성대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 경성대학교: UniversityType {
  
  var name: String {
    return "경성대학교"
  }
  
  var categories: [Category] {
    return [
      ("MN093", "학사"),
      ("MN094", "장학"),
      ("MN095", "취업"),
      ("MN091", "교내"),
      ("MN092", "교외"),
      ("MN0006", "봉사")
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
        let links = document.xpath("//tbody//tr//td[@class='subject']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 5
          let titleIndex = index * 5 + 1
          let dateIndex = index * 5 + 3
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

extension 경성대학교 {
  
  var baseURL: String {
    return "http://kscms.ks.ac.kr/kor/CMS/Board/Board.do"
  }
  
  var commonQueries: String {
    return "?searchID=sch001"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&mCode=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchKeyword=\(text.percentEncoded)"
  }
}
