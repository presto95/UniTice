//
//  KAIST.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct KAIST: UniversityType {
  
  var name: String {
    return "KAIST"
  }
  
  var categories: [Category] {
    return [
      ("kaist_event", "알림사항"),
      ("kaist_student", "학사공지"),
      ("kr_events", "행사 안내")
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

extension KAIST {
  
  var baseURL: String {
    return "https://www.kaist.ac.kr/_prog/_board/"
  }
  
  var commonQueries: String {
    return "index.php?"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&code=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&GotoPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&skey=title&sval=\(text.percentEncoding)"
  }
}
