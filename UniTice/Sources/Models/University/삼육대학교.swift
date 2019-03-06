//
//  삼육대학교.swift
//  UniTice
//
//  Created by Presto on 05/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 삼육대학교: UniversityScrappable {
  
  var name: String {
    return "삼육대학교"
  }
  
  var categories: [Category] {
    return [
      ("", "전체"),
      ("수업", "수업"),
      ("학적", "학적"),
      ("등록", "등록"),
      ("채플", "채플")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: link) else {
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
        let numbers = document.xpath("//tbody//tr//th")
        let titles = document.xpath("//tbody//tr//td[@class='step2']//span[@class='tit']")
        let dates = document.xpath("//tbody//tr//td[@class='step4']")
        let links = document.xpath("//tbody//tr//td[@class='step2']//a/@href")
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

extension 삼육대학교 {
  
  var baseURL: String {
    return "https://new.syu.ac.kr"
  }
  
  var commonQueries: String {
    return "/academic/academic-notice?c=title"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&t=\(category.identifier.percentEncoding)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&k=\(text.percentEncoding)"
  }
}
