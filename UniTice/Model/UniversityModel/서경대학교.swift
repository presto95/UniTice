//
//  서경대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 서경대학교: UniversityScrappable {
  
  var name: String {
    return "서경대학교"
  }
  
  var categories: [서경대학교.Category] {
    return [
      ("80966", "일반"),
      ("80968", "학사"),
      ("80970", "장학"),
      ("80972", "입학"),
      ("115807", "행사안내")
    ]
  }
  
  func postURL(inCategory category: 서경대학교.Category, uri link: String) -> URL {
    guard let url = URL(string: link.percentEncoding) else {
      fatalError()
    }
    return url
  }
  
  func requestPosts(inCategory category: 서경대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    KannaManager.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let numbers = doc.xpath("//tbody//tr//td[1]")
      let titles = doc.xpath("//tbody//tr//td[@class='title']//a")
      let dates = doc.xpath("//tbody//tr//td[@class='date']")
      let links = doc.xpath("//tbody//tr//td[@class='title']//a/@href")
      for (index, element) in links.enumerated() {
        let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
        let title = titles[index].text?.trimmed ?? "?"
        let date = dates[index].text?.trimmed ?? "?"
        let link = element.text?.trimmed ?? "?"
        let post = Post(number: number, title: title, date: date, link: link)
        posts.append(post)
      }
      completion(posts, nil)
    }
  }
}

extension 서경대학교 {
  var baseURL: String {
    return "https://www.skuniv.ac.kr/index.php?mid=notice"
  }
  
  var commonQueries: String {
    return "&search_target=title"
  }
  
  func categoryQuery(_ category: 서경대학교.Category) -> String {
    return "&category=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search_keyword=\(text.percentEncoding)"
  }
}
