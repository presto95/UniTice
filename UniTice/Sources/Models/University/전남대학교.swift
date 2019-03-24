//
//  Jnu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 전남대학교: UniversityType {
  
  var name: String {
    return "전남대학교"
  }
  
  var categories: [Category] {
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
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        let rows = document.xpath("//table[@class='board_list']//tbody//td")
        let links = document.xpath("//table[@class='board_list']//tbody//td[@class='title']//a/@href")
        return links.enumerated().map { index, element in
          let numberIndex = index * 5
          let titleIndex = index * 5 + 1
          let dateIndex = index * 5 + 3
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

extension 전남대학교 {
  
  var baseURL: String {
    return "http://www.jnu.ac.kr"
  }
  
  var commonQueries: String {
    return "/WebApp/web/HOM/COM/Board/board.aspx?boardID=5&bbsMode=list&searchTarget=title"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&cate=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&keyword=\(text.percentEncoded)"
  }
}
