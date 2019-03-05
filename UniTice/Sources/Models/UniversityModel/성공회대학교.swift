//
//  성공회대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 성공회대학교: UniversityScrappable {
  
  var name: String {
    return "성공회대학교"
  }
  
  var categories: [성공회대학교.Category] {
    return [
      ("10004", "학사공지"),
      ("10005", "수업공지"),
      ("10038", "학점교류"),
      ("10006", "장학공지"),
      ("10007", "일반공지"),
      ("10008", "행사공지")
    ]
  }
  
  func requestPosts(inCategory category: 성공회대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page, searchText: text), encoding: .eucKR) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody//tr//td")
      let links = doc.xpath("//tbody//tr//td[2]//a/@href")
      for (index, element) in links.enumerated() {
        let numberIndex = index * 6
        let titleIndex = index * 6 + 1
        let dateIndex = index * 6 + 4
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

extension 성공회대학교 {
  var baseURL: String {
    return "http://www.skhu.ac.kr/board/"
  }
  
  var commonQueries: String {
    return "boardlist.aspx?searchType=1"
  }
  
  func categoryQuery(_ category: 성공회대학교.Category) -> String {
    return "&bsid=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&curpage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchWord=\(text.percentEncoding)"
  }
}
