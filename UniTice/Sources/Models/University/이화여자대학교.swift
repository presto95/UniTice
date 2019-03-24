//
//  이화여자대학교.swift
//  UniTice
//
//  Created by Presto on 02/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 이화여자대학교: UniversityType {
  
  var name: String {
    return "이화여자대학교"
  }
  
  var categories: [Category] {
    return [
      ("", "전체"),
      ("0002", "일반"),
      ("0003", "학사"),
      ("0007", "장학"),
      ("0004", "경력"),
      ("0005", "입학"),
      ("0008", "등록금"),
      ("0006", "입찰")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//tr//td//p//a/@href")
        return links.enumerated().map { index, element in
          let numberIndex = index * 4
          let titleIndex = index * 4 + 2
          let dateIndex = index * 4 + 3
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          return Post(number: number, title: title, date: date, link: link)
        }
      }
      .catchErrorJustReturn([])
  }
}

extension 이화여자대학교 {
  
  var baseURL: String {
    return "http://www.ewha.ac.kr/mbs/ewhakr/jsp/board/"
  }
  
  var commonQueries: String {
    return "list.jsp?boardId=13259&id=ewhakr_070200000000&column=TITLE"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&categoryDepth=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&spage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoded)"
  }
}
