//
//  세종대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 세종대학교: UniversityType {
  
  var name: String {
    return "세종대학교"
  }
  
  var categories: [Category] {
    return [
      ("333", "공지"),
      ("335", "학사"),
      ("674", "국제교류"),
      ("337", "취업/장학"),
      ("339", "교내모집")
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

extension 세종대학교 {
  
  var baseURL: String {
    return "http://board.sejong.ac.kr"
  }
  
  var commonQueries: String {
    return "/boardlist.do?searchField=D.TITLE"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchValue=\(text.percentEncoded)"
  }
}
