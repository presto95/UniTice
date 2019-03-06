//
//  Dongduk.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 동덕여자대학교: UniversityScrappable {
  
  var name: String {
    return "동덕여자대학교"
  }
  
  var categories: [Category] {
    return [
      ("ALL", "전체"),
      ("42", "교무처"),
      ("43", "학생처"),
      ("44", "사무처"),
      ("45", "기획처"),
      ("46", "예산관재처"),
      ("57", "입학처"),
      ("48", "춘강학술정보관"),
      ("56", "대학원"),
      ("47", "산학협력단"),
      ("50", "교무위원회"),
      ("49", "기타"),
      ("58", "총장실")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts = [Post]()
        let numbers = document.xpath("//tbody//td[@class='td-01']")
        let titles = document.xpath("//tbody//td[@class='td-03']//h6[@class='subject']//a")
        let links = document.xpath("//tbody//td[@class='td-03']//h6[@class='subject']//a/@href")
        let dates = document.xpath("//tbody//td[@class='td-05']")
        titles.enumerated().forEach { index, element in
          let number = Int(numbers[index].text ?? "") ?? 0
          let title = element.text?.trimmed ?? "?"
          let link = links[index].text?.trimmed ?? "?"
          let date = dates[index].text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 동덕여자대학교 {
  
  var baseURL: String {
    return "https://www.dongduk.ac.kr"
  }
  
  var commonQueries: String {
    return "/front/boardlist.do?bbsConfigFK=101"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&searchLowItem=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchField=TITLE&searchValue=\(text.percentEncoding)"
  }
}
