//
//  성균관대학교.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 성균관대학교: UniversityType {
  
  var name: String {
    return "성균관대학교"
  }
  
  var categories: [Category] {
    return [
      ("01", "전체"),
      ("02", "학사"),
      ("03", "입학"),
      ("04", "취업"),
      ("05", "채용/모집"),
      ("06", "장학"),
      ("07", "행사/세미나"),
      ("07", "일반")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(commonQueries)\(categoryQuery(category))\(link.percentEncoded)") else {
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
        let numbers = document.xpath("//table[@class='board_list']//tbody//td[1]")
        let titles = document.xpath("//table[@class='board_list']//tbody//td[@class='left']//a")
        let dates = document.xpath("//table[@class='board_list']//tbody//td[3]")
        let links = document.xpath("//table[@class='board_list']//tbody//td[@class='left']//a/@href")
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

extension 성균관대학교 {
  
  var baseURL: String {
    return "https://www.skku.edu/skku/campus/skk_comm/"
  }
  
  var commonQueries: String {
    return "notice"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "\(category.identifier).do"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "?mode=list&srSearchKey=article_title&article.offset=\((page - 1) * 10)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&srSearchVal=\(text.percentEncoded)"
  }
}
