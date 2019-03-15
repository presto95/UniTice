//
//  한성대학교.swift
//  UniTice
//
//  Created by Presto on 02/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 한성대학교: UniversityType {
  
  var name: String {
    return "한성대학교"
  }
  
  var categories: [Category] {
    return [
      ("cmty_01_01", "공지사항"),
      ("cmty_01_03", "학사공지"),
      ("552", "장학공지")
    ]
  }
  
  func pageURL(inCategory category: Category, inPage page: Int, searchText text: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(categoryQuery(category))\(commonQueries)\(pageQuery(page))\(searchQuery(text))") else {
      return nil
    }
    return url
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: link) else {
      return nil
    }
    return url
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//tr//td[@class='subject']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 6
          let titleIndex: Int
          if category.identifier == "552" {
            titleIndex = index * 6 + 2
          } else {
            titleIndex = index * 6 + 1
          }
          let dateIndex = index * 6 + 4
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 한성대학교 {
  
  var baseURL: String {
    return "https://www.hansung.ac.kr/web/www/"
  }
  
  var commonQueries: String {
    return "?p_p_id=EXT_BBS&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=3&_EXT_BBS_struts_action=%2Fext%2Fbbs%2Fview&_EXT_BBS_sCategory=&_EXT_BBS_sKeyType=title"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return category.identifier
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&_EXT_BBS_curPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&_EXT_BBS_sKeyword=\(text.percentEncoded)"
  }
}
