//
//  제주대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 제주대학교: UniversityScrappable {
  
  var name: String {
    return "제주대학교"
  }
  
  var categories: [Category] {
    return [
      ("notice", "JNU소식"),
      ("degree", "학사안내"),
      ("exchange", "국내교류수학안내"),
      ("recruit", "채용안내"),
      ("scholarship", "장학안내"),
      ("event", "알림및행사안내"),
      ("outEvent", "외부기관행사"),
      ("service", "봉사안내")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: link.percentEncoding) else {
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
        let rows = document.xpath("//table[@class='table border_top_blue list']//tbody//td")
        let links = document.xpath("//table[@class='table border_top_blue list']//tbody//a/@href")
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

extension 제주대학교 {
  
  var baseURL: String {
    return "http://www.jejunu.ac.kr/ara/"
  }
  
  var commonQueries: String {
    return ""
  }
  
  func categoryQuery(_ category: Category) -> String {
    return category.identifier
  }
  
  func pageQuery(_ page: Int) -> String {
    return "?page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&s%5Bs%5D=subject&s%5Bq%5D=\(text.percentEncoding)"
  }
}
