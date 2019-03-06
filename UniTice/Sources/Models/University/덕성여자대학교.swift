//
//  덕성여자대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 덕성여자대학교: UniversityScrappable {
  
  var name: String {
    return "덕성여자대학교"
  }
  
  var categories: [Category] {
    return [
      ("ALL", "전체"),
      ("B3001001", "학사안내"),
      ("B3001011", "장학안내"),
      ("B3001002", "행사안내"),
      ("B3001003", "산학/연구"),
      ("B3001005", "취업"),
      ("B3001004", "기타")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(link)") else {
      return nil
    }
    return url
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .eucKR)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//tr//td[@class='title']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 7
          let titleIndex = index * 7 + 2
          let dateIndex = index * 7 + 5
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let tempLink = element.text?.trimmed.map { String($0) } ?? []
          var link = ""
          for character in tempLink {
            if let digit = Int(character) {
              link += "\(digit)"
            }
          }
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 덕성여자대학교 {
  
  var baseURL: String {
    return "http://www.duksung.ac.kr/news/"
  }
  
  var commonQueries: String {
    return "notice_list.jsp?boardFlag=0&searchTarget=SUBJECT"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&category=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&cpage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&keyword=\(text.percentEncoding)"
  }
  
  private var commonQueriesForPost: String {
    return "notice_read.jsp?boardFlag=0&idx="
  }
}
