//
//  Jnu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct 전남대학교: UniversityScrappable {
  
  var name: String {
    return "전남대학교"
  }
  
  var categories: [전남대학교.Category] {
    return [
      ("0", "전체"),
      ("5", "학사안내"),
      ("6", "대학생활"),
      ("7", "취업정보"),
      ("8", "장학안내"),
      ("9", "행사안내"),
      ("10", "병무안내"),
      ("11", "공사안내"),
      ("12", "입찰공고"),
      ("13", "채용공고"),
      ("14", "IT뉴스"),
      ("15", "공모전"),
      ("16", "모집공고"),
      ("17", "학술연구"),
      ("842", "직원표창공개"),
      ("1367", "행정공고")
    ]
  }
  
  func requestPosts(inCategory category: 전남대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
    KannaManager.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//table[@class='board_list']//tbody//td")
      let links = doc.xpath("//table[@class='board_list']//tbody//td[@class='title']//a/@href")
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

extension 전남대학교 {
  var baseURL: String {
    return "http://www.jnu.ac.kr"
  }
  
  var commonQueries: String {
    return "/WebApp/web/HOM/COM/Board/board.aspx?boardID=5&bbsMode=list&searchTarget=title"
  }
  
  func categoryQuery(_ category: 전남대학교.Category) -> String {
    return "&cate=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&keyword=\(text.percentEncoding)"
  }
}
