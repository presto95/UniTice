//
//  부산대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct 부산대학교: UniversityScrappable {
  
  var name: String {
    return "부산대학교"
  }
  
  var categories: [부산대학교.Category] {
    return [
      ("MN095", "공지사항")
    ]
  }
  
  func requestPosts(inCategory category: 부산대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseManager.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//table[@class='board-list-table']//tbody//td")
      let links = doc.xpath("//table[@class='board-list-table']//tbody//td[@class='subject']//a/@href")
      for (index, element) in links.enumerated() {
        let numberIndex = index * 5
        let titleIndex = index * 5 + 1
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

extension 부산대학교 {
  var baseURL: String {
    return "https://www.pusan.ac.kr/kor/CMS/Board/Board.do"
  }
  
  var commonQueries: String {
    return "?robot=Y&mgr_seq=3&mode=list"
  }
  
  func categoryQuery(_ category: 부산대학교.Category) -> String {
    return "&mCode=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchID=title&searchKeyword=\(text.percentEncoding)"
  }
}
