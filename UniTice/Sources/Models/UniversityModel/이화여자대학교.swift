//
//  이화여자대학교.swift
//  UniTice
//
//  Created by Presto on 02/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 이화여자대학교: UniversityScrappable {
  
  var name: String {
    return "이화여자대학교"
  }
  
  var categories: [이화여자대학교.Category] {
    return [
      ("", "전체"),
      ("0002", "일반"),
      ("0003", "학사"),
      ("0007", "장학"),
      ("0004", "경력"),
      ("0005", "입학"),
      ("0008", "등록금"),
      ("0006", "입찰")
    ]
  }
  
  func requestPosts(inCategory category: 이화여자대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody//tr//td")
      let links = doc.xpath("//tbody//tr//td//p//a/@href")
      for (index, element) in links.enumerated() {
        let numberIndex = index * 4
        let titleIndex = index * 4 + 2
        let dateIndex = index * 4 + 3
        let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
        let title = rows[titleIndex].text?.trimmed ?? "?"
        let date = rows[dateIndex].text?.trimmed ?? "?"
        let link = element.text?.trimmed ?? "?"
        let post = Post(number: number, title: title, date: date, link: link)
        posts.append(post)
      }
      completion(posts, nil)
    }
  }
}

extension 이화여자대학교 {
  var baseURL: String {
    return "http://www.ewha.ac.kr/mbs/ewhakr/jsp/board/"
  }
  
  var commonQueries: String {
    return "list.jsp?boardId=13259&id=ewhakr_070200000000&column=TITLE"
  }
  
  func categoryQuery(_ category: 이화여자대학교.Category) -> String {
    return "&categoryDepth=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&spage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoding)"
  }
}
