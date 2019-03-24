//
//  충북대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 충북대학교: UniversityType {
  
  var name: String {
    return "충북대학교"
  }
  
  var categories: [Category] {
    return [
      ("112", "공지사항"),
      ("113", "학사/장학"),
      ("114", "행사/세미나공지")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        let rows = document.xpath("//table[@class='basic']//tbody[@class='tb']//td")
        let links = document.xpath("//table[@class='basic']//tbody[@class='tb']//td[@class='subject']//a/@href")
        let divisor: Int
        switch category.identifier {
        case "112", "113":
          divisor = 6
        default:
          divisor = 4
        }
        return links.enumerated().map { index, element in
          let numberIndex = index * divisor
          let titleIndex = index * divisor + 1
          let dateIndex = index * divisor + divisor - 1
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          var link = element.text?.trimmed ?? "?"
          link.removeFirst()
          return Post(number: number, title: title, date: date, link: link)
        }
      }
      .catchErrorJustReturn([])
  }
}

extension 충북대학교 {
  
  var baseURL: String {
    return "http://www.chungbuk.ac.kr/site/www"
  }
  
  var commonQueries: String {
    return "/boardList.do?key=698&searchType=TITLE"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&boardSeq=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchKeyword=\(text.percentEncoded)"
  }
}
