//
//  성신여자대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 성신여자대학교: UniversityScrappable {
  
  var name: String {
    return "성신여자대학교"
  }
  
  var categories: [성신여자대학교.Category] {
    return [
      ("comm010101", "학사공지"),
      ("comm010201", "일반공지"),
      ("comm010301", "입학공지"),
      ("comm010401", "취업공지"),
      ("comm010601", "교내채용")
    ]
  }
  
  func pageURL(inCategory category: 성신여자대학교.Category, inPage page: Int, searchText text: String) -> URL {
    guard let url = URL(string: "\(baseURL)\(categoryQuery(category))\(commonQueries)\(pageQuery(page))\(searchQuery(text))") else {
      fatalError()
    }
    return url
  }
  
  func postURL(inCategory category: 성신여자대학교.Category, uri link: String) -> URL {
    guard let url = URL(string: link) else {
      fatalError()
    }
    return url
  }
  
  func requestPosts(inCategory category: 성신여자대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
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

extension 성신여자대학교 {
  var baseURL: String {
    return "http://new.sungshin.ac.kr/web/kor/"
  }
  
  var commonQueries: String {
    return "?p_p_id=EXT_BBS&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=2&_EXT_BBS_struts_action=%2Fext%2Fbbs%2Fview&_EXT_BBS_sCategory=&_EXT_BBS_sWriter=&_EXT_BBS_sTag=&_EXT_BBS_sContent=&_EXT_BBS_sCategory2=&_EXT_BBS_sKeyType=title"
  }
  
  func categoryQuery(_ category: 성신여자대학교.Category) -> String {
    return category.identifier
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&_EXT_BBS_curPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&_EXT_BBS_sTitle=\(text.percentEncoding)&_EXT_BBS_sKeyword=\(text.percentEncoding)"
  }
}
