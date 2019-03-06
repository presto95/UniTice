//
//  충남대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 충남대학교: UniversityScrappable {
  
  var name: String {
    return "충남대학교"
  }
  
  var categories: [Category] {
    return [
      ("0701", "새소식"),
      ("0702", "학사정보"),
      ("0704", "교육정보"),
      ("0709", "사업단 창업ㆍ교육"),
      ("0705", "채용/초빙")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//div[@class='board_list']//tbody//td")
        let links = document.xpath("//div[@class='board_list']//tbody//td[@class='title']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 6
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 3
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          var realLink = element.text?.trimmed ?? "?"
          realLink.removeFirst()
          let post = Post(number: number, title: title, date: date, link: realLink)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 충남대학교 {
  
  var baseURL: String {
    return "http://plus.cnu.ac.kr/_prog/_board/"
  }
  
  var commonQueries: String {
    return "?site_dvs_cd=kr&site_dvs=&ntt_tag="
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&menu_dvs_cd=\(category.identifier)&code=sub07_\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&GotoPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&skey=title&sval=\(text.percentEncoding)"
  }
}
