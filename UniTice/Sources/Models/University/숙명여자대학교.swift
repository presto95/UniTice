//
//  숙명여자대학교.swift
//  UniTice
//
//  Created by Presto on 05/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 숙명여자대학교: UniversityType {
  
  var name: String {
    return "숙명여자대학교"
  }
  
  var categories: [Category] {
    return [
      ("58", "공지"),
      ("59", "학사"),
      ("60", "장학"),
      ("61", "입학"),
      ("134", "모집"),
      ("62", "IT")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        let numbers = document.xpath("//tbody//tr//td[@class='num']")
        let titles = document.xpath("//tbody//tr//td//p[@class='title']")
        let dates = document.xpath("//tbody//tr//ul[@class='name']//li[@class='date']")
        let links = document.xpath("//tbody//tr//td//p[@class='title']//a/@href")
        return links.enumerated().map { index, element in
          let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
          let title = titles[index].text?.trimmed ?? "?"
          let date = dates[index].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          return Post(number: number, title: title, date: date, link: link)
        }
      }
      .catchErrorJustReturn([])
  }
}

extension 숙명여자대학교 {
  
  var baseURL: String {
    return "http://www.sookmyung.ac.kr"
  }
  
  var commonQueries: String {
    return "/bbs/sookmyungkr/66/artclList.do?srchColumn=sj"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bbsClSeq=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&srchWrd=\(text.percentEncoded)"
  }
}
