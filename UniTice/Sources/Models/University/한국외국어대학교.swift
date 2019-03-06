//
//  한국외국어대학교.swift
//  UniTice
//
//  Created by Presto on 31/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 한국외국어대학교: UniversityScrappable {
  
  var name: String {
    return "한국외국어대학교"
  }
  
  var categories: [Category] {
    return [
      ("37079", "공지"),
      ("37080", "장학"),
      ("37082", "채용"),
      ("37083", "구매/공사실적")
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
        let links = document.xpath("//tbody//tr//td[@class='title']//a/@href")
        let campuses = ["[공통]", "[서울]", "[글로벌]"]
        links.enumerated().forEach { index, element in
          let numberIndex = index * 6
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 3
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          var title = rows[titleIndex].text?.trimmed ?? "?"
          for campus in campuses {
            if let range = title.range(of: campus) {
              title.removeSubrange(range)
              title = title.trimmed
              title = "\(campus) \(title)"
              break
            }
          }
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

extension 한국외국어대학교 {
  
  var baseURL: String {
    return "http://builder.hufs.ac.kr/user/"
  }
  
  var commonQueries: String {
    return "indexSub.action?siteId=hufs&column=title"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&codyMenuSeq=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoding)"
  }
}
