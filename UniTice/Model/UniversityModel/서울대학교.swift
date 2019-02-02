//
//  Snu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct 서울대학교: UniversityScrappable {
  
  var name: String {
    return "서울대학교"
  }
  
  var categories: [서울대학교.Category] {
    return [
      ("notice", "일반공지")
    ]
  }
  
  func requestPosts(inCategory category: 서울대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
    KannaManager.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//table[@class='table01n_list']//tbody//td")
      let links = doc.xpath("//table[@class='table01n_list']//tbody//a/@href")
      for (index, element) in links.enumerated() {
        let numberIndex = index * 4
        let titleIndex = index * 4 + 1
        let dateIndex = index * 4 + 2
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

extension 서울대학교 {
  var baseURL: String {
    return "http://www.snu.ac.kr/"
  }
  
  var commonQueries: String {
    return ""
  }
  
  func categoryQuery(_ category: 서울대학교.Category) -> String {
    return category.identifier
  }
  
  func pageQuery(_ page: Int) -> String {
    return "?page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&bt=t&bq=\(text.percentEncoding)"
  }
}
