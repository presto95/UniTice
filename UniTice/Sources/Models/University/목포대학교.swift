//
//  목포대학교.swift
//  UniTice
//
//  Created by Presto on 03/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 목포대학교: UniversityScrappable {
  
  var name: String {
    return "목포대학교"
  }
  
  var categories: [Category] {
    return [
      ("4b6a9cdf445f672b01446172abb0008e", "일반공지"),
      ("402848ef440a7c1201440ff01edf02a5", "학사공지"),
      ("402848ef43d24e450143d293a1e4010c", "교내채용공고"),
      ("402848ef440a7c1201441072d65e051f", "취업공지")
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
          let dateIndex = index * 6 + 4
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed.dropFirst().description ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 목포대학교 {
  
  var baseURL: String {
    return "http://www.mokpo.ac.kr/planweb/board"
  }
  
  var commonQueries: String {
    return "/list.9is?searchType=dataTitle"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&boardUid=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&nowPageNum=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&keyword=\(text.percentEncoding)"
  }
}
