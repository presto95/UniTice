//
//  홍익대학교.swift
//  UniTice
//
//  Created by Presto on 31/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 홍익대학교: UniversityType {
  
  var name: String {
    return "홍익대학교"
  }
  
  var categories: [Category] {
    return [
      ("2", "일반공지"),
      ("3", "학생공지"),
      ("4", "교강사공지"),
      ("10", "세종캠퍼스공지"),
      ("9", "대학원공지"),
      ("6", "행사/공모전"),
      ("2", "일반공지")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//td//div[@class='subject']//a/@href")
        return links.enumerated().map { index, element in
          let numberIndex = index * 6
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 4
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

extension 홍익대학교 {
  var baseURL: String {
    return "http://www.hongik.ac.kr"
  }
  
  var commonQueries: String {
    return "/front/boardlist.do?searchField=D.TITLE"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchValue=\(text.percentEncoded)"
  }
  
}
