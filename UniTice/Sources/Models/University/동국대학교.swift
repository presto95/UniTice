//
//  동국대학교.swift
//  UniTice
//
//  Created by Presto on 31/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 동국대학교: UniversityType {
  
  var name: String {
    return "동국대학교"
  }
  
  var categories: [Category] {
    return [
      ("3646", "일반공지"),
      ("3638", "학사공지"),
      ("3654", "입시공지"),
      ("3662", "장학공지"),
      ("9457435", "국제공지"),
      ("11533472", "학술/행사공지")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//td")
        let links = document.xpath("//tbody//td[@class='title']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 7
          let titleIndex = index * 7 + 1
          let dateIndex = index * 7 + 3
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

extension 동국대학교 {
  
  var baseURL: String {
    return "https://www.dongguk.edu/mbs/kr/jsp/board/"
  }
  
  var commonQueries: String {
    return "list.jsp?column=TITLE&mcategoryId=0&boardType=01&listType=01&command=list"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&boardId=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&spage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoding)"
  }
}
