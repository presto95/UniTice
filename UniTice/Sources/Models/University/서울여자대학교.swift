//
//  서울여자대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 서울여자대학교: UniversityType {
  
  var name: String {
    return "서울여자대학교"
  }
  
  var categories: [Category] {
    return [
      ("4", "학사"),
      ("5", "장학"),
      ("6", "행사"),
      ("7", "채용/취업"),
      ("8", "일반/봉사")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(commonQueriesForPost(category))\(link)") else {
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
        let links = document.xpath("//tbody//tr//td[@class='title']//a/@onclick")
        links.enumerated().forEach { index, element in
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
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 서울여자대학교 {
  
  var baseURL: String {
    return "http://www.swu.ac.kr/front"
  }
  
  var commonQueries: String {
    return "/boardlist.do?"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchField=D.TITLE&searchValue=\(text.percentEncoding)"
  }
  
  private func commonQueriesForPost(_ category: Category) -> String {
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
