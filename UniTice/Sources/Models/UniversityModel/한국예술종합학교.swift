//
//  한국예술종합학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 한국예술종합학교: UniversityScrappable {
  
  var name: String {
    return "한국예술종합학교"
  }
  
  var categories: [한국예술종합학교.Category] {
    return [
      ("공고", "공고"),
      ("공연/전시", "공연/전시"),
      ("국제교류", "국제교류"),
      ("병무/예비군", "병무/예비군"),
      ("복지/편의", "복지/편의"),
      ("언론", "언론"),
      ("입시", "입시"),
      ("장학/생활", "장학/생활"),
      ("취업/채용", "취업/채용"),
      ("교내공모", "교내공모"),
      ("천장관", "천장관"),
      ("학사", "학사"),
      ("행사/소식", "행사/소식")
    ]
  }
  
  func requestPosts(inCategory category: 한국예술종합학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody//tr//td")
      let links = doc.xpath("//tbody//tr//td[@class='left']//a/@href")
      for (index, element) in links.enumerated() {
        let numberIndex = index * 5
        let titleIndex = index * 5 + 2
        let dateIndex = index * 5 + 3
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

extension 한국예술종합학교 {
  var baseURL: String {
    return "http://www.karts.ac.kr"
  }
  
  var commonQueries: String {
    return "/nri/bbs/NuriBbsList.do?bbsId=BBSNURI_001&searchCondition=0"
  }
  
  func categoryQuery(_ category: 한국예술종합학교.Category) -> String {
    return "&searchType=\(category.identifier.percentEncoding)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&pageIndex=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchKeyword=\(text.percentEncoding)"
  }
}
