//
//  대진대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 대진대학교: UniversityScrappable {
  
  var name: String {
    return "대진대학교"
  }
  
  var categories: [대진대학교.Category] {
    return [
      ("2", "일반"),
      ("1", "학사"),
      ("4", "장학"),
      ("5", "취업"),
      ("3", "입찰")
    ]
  }
  
  func requestPosts(inCategory category: 대진대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    KannaManager.shared.request(pageURL(inCategory: category, inPage: page, searchText: text), encoding: .eucKR) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let fixedCount = doc.xpath("//tbody//tr[@class='hot ']").count
      let numbers = doc.xpath("//tbody//tr//td[1]")
      let titles = doc.xpath("//tbody//tr//td[2]")
      let dates = doc.xpath("//tbody//tr//td[4]")
      let links = doc.xpath("//tbody//tr//td[2]//a/@href")
      for (index, element) in numbers.enumerated() {
        let number = Int(element.text?.trimmed ?? "") ?? 0
        let title = titles[index].text?.trimmed ?? "?"
        let link = links[index].text?.trimmed.dropFirst().description ?? "?"
        let date = number == 0 ? "" : dates[index - fixedCount].text?.trimmed ?? "?"
        let post = Post(number: number, title: title, date: date, link: link)
        posts.append(post)
      }
      completion(posts, nil)
    }
  }
}

extension 대진대학교 {
  var baseURL: String {
    return "http://www.daejin.ac.kr"
  }
  
  var commonQueries: String {
    return "/front/unitedboardlist.do?type=N&searchField=TITLE"
  }
  
  func categoryQuery(_ category: 대진대학교.Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchValue=\(text.percentEncoding)"
  }
}
