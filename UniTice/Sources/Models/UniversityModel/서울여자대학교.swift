//
//  서울여자대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 서울여자대학교: UniversityScrappable {
  
  var name: String {
    return "서울여자대학교"
  }
  
  var categories: [서울여자대학교.Category] {
    return [
      ("4", "학사"),
      ("5", "장학"),
      ("6", "행사"),
      ("7", "채용/취업"),
      ("8", "일반/봉사")
    ]
  }
  func postURL(inCategory category: 서울여자대학교.Category, uri link: String) -> URL {
    guard let url = URL(string: "\(baseURL)\(commonQueriesForPost(category))\(link)") else {
      fatalError()
    }
    return url
  }
  
  func requestPosts(inCategory category: 서울여자대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody//tr//td")
      let links = doc.xpath("//tbody//tr//td[@class='title']//a/@onclick")
      for (index, element) in links.enumerated() {
        let numberIndex = index * 5
        let titleIndex = index * 5 + 1
        let dateIndex = index * 5 + 3
        let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
        let title = rows[titleIndex].at_xpath("div//div")?.text?.trimmed ?? "?"
        let date = rows[dateIndex].text?.trimmed ?? "?"
        let link = element.text?.trimmed.filter { Int("\($0)") != nil } ?? "?"
        let post = Post(number: number, title: title, date: date, link: link)
        posts.append(post)
      }
      completion(posts, nil)
    }
  }
}

extension 서울여자대학교 {
  var baseURL: String {
    return "http://www.swu.ac.kr/front"
  }
  
  var commonQueries: String {
    return "/boardlist.do?"
  }
  
  func categoryQuery(_ category: 서울여자대학교.Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchField=D.TITLE&searchValue=\(text.percentEncoding)"
  }
  
  private func commonQueriesForPost(_ category: 서울여자대학교.Category) -> String {
    var cate = ""
    switch category.identifier {
    case "4":
      cate += "336"
    case "5":
      cate += "337"
    case "6":
      cate += "338"
    case "7":
      cate += "339"
    case "8":
      cate += "340"
    default:
      cate += ""
    }
    return "/mboardview.do?cmsDirPkid=\(cate)&cmsLocalPkid=0&bbsConfigFK=\(category.identifier)&pkid="
  }
}
