//
//  서경대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 서경대학교: UniversityScrappable {
  
  var name: String {
    return "서경대학교"
  }
  
  var categories: [Category] {
    return [
      ("80966", "일반"),
      ("80968", "학사"),
      ("80970", "장학"),
      ("80972", "입학"),
      ("115807", "행사안내")
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
        let numbers = document.xpath("//tbody//tr//td[1]")
        let titles = document.xpath("//tbody//tr//td[@class='title']//a")
        let dates = document.xpath("//tbody//tr//td[@class='date']")
        let links = document.xpath("//tbody//tr//td[@class='title']//a/@href")
        links.enumerated().forEach { index, element in
          let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
          let title = titles[index].text?.trimmed ?? "?"
          let date = dates[index].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 서경대학교 {
  
  var baseURL: String {
    return "https://www.skuniv.ac.kr/index.php?mid=notice"
  }
  
  var commonQueries: String {
    return "&search_target=title"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&category=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search_keyword=\(text.percentEncoding)"
  }
}
