//
//  대진대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 대진대학교: UniversityScrappable {
  
  var name: String {
    return "대진대학교"
  }
  
  var categories: [Category] {
    return [
      ("2", "일반"),
      ("1", "학사"),
      ("4", "장학"),
      ("5", "취업"),
      ("3", "입찰")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .eucKR)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//div[2]//tbody//tr//td")
        let links = document.xpath("//div[2]//tbody//tr//td//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 4
          let titleIndex = index * 4 + 1
          let dateIndex = index * 4 + 2
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

extension 대진대학교 {
  
  var baseURL: String {
    return "http://www.daejin.ac.kr"
  }
  
  var commonQueries: String {
    return "/front/unitedboardlist.do?type=N&searchField=TITLE"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchValue=\(text.percentEncoding)"
  }
}
