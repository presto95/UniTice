//
//  덕성여자대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 덕성여자대학교: UniversityScrappable {
  
  var name: String {
    return "덕성여자대학교"
  }
  
  var categories: [덕성여자대학교.Category] {
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
  
  func postURL(inCategory category: 덕성여자대학교.Category, uri link: String) -> URL {
    guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(link)") else {
      fatalError()
    }
    return url
  }
  
  func requestPosts(inCategory category: 덕성여자대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page - 1, searchText: text), encoding: .eucKR) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody//tr//td")
      let links = doc.xpath("//tbody//tr//td[@class='title']//a/@href")
      for (index, element) in links.enumerated() {
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
      completion(posts, nil)
    }
  }
}

extension 덕성여자대학교 {
  var baseURL: String {
    return "http://www.duksung.ac.kr/news/"
  }
  
  var commonQueries: String {
    return "notice_list.jsp?boardFlag=0&searchTarget=SUBJECT"
  }
  
  func categoryQuery(_ category: 덕성여자대학교.Category) -> String {
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
