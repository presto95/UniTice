//
//  성결대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 성결대학교: UniversityScrappable {
  
  var name: String {
    return "성결대학교"
  }
  
  var categories: [성결대학교.Category] {
    return [
      ("33", "새소식"),
      ("29", "학사"),
      ("34", "장학/등록/학자금"),
      ("35", "입학"),
      ("90", "취업/진로개발/창업"),
      ("36", "공모/행사"),
      ("37", "교육/글로벌"),
      ("38", "일반"),
      ("39", "입찰구매정보"),
      ("108", "사회봉사/장애/상담")
    ]
  }
  
  func requestPosts(inCategory category: 성결대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseManager.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody//tr//td")
      let links = doc.xpath("//tbody//tr//td//a/@href")
      for (index, element) in links.enumerated() {
        let multiplier = category.identifier == "90" || category.identifier == "108" ? 6 : 5
        let numberIndex = index * multiplier
        let titleIndex = index * multiplier + 1
        let dateIndex = index * multiplier + multiplier - 3
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

extension 성결대학교 {
  var baseURL: String {
    return "https://www.sungkyul.ac.kr/mbs/skukr/jsp/board/"
  }
  
  var commonQueries: String {
    return "list.jsp?column=TITLE"
  }
  
  func categoryQuery(_ category: 성결대학교.Category) -> String {
    return "&boardId=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&spage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoding)"
  }
}
