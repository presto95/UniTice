//
//  우석대학교.swift
//  UniTice
//
//  Created by Presto on 08/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 우석대학교: UniversityType {
  
  var name: String {
    return "우석대학교"
  }
  
  var categories: [Category] {
    return [
      ("B0199", "학사공지"),
      ("B0022", "일반공지"),
      ("B0062", "행사 및 알림"),
      ("B0022", "자유게시판")
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
        let links = document.xpath("//tbody//tr//td//a/@href")
        links.enumerated().forEach { index, element in
          let multiplier = category.identifier == "B0022" ? 7 : 6
          let numberIndex = index * multiplier
          let titleIndex = index * multiplier + multiplier - 5
          let dateIndex = index * multiplier + multiplier - 2
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

extension 우석대학교 {
  
  var baseURL: String {
    return "https://www.woosuk.ac.kr"
  }
  
  var commonQueries: String {
    return "/boardList.do?paramField=title"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bcode=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&PF=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&paramKeyword=\(text.percentEncoded)"
  }
}
