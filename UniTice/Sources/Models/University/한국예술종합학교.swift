//
//  한국예술종합학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 한국예술종합학교: UniversityScrappable {
  
  var name: String {
    return "한국예술종합학교"
  }
  
  var categories: [Category] {
    return [
      ("공고", "공고"),
      ("공연/전시", "공연/전시"),
      ("국제교류", "국제교류"),
      ("병무/예비군", "병무/예비군"),
      ("복지/편의", "복지/편의"),
      ("언론", "언론"),
      ("입시", "입시"),
      ("장학/생활", "장학/생활"),
      ("취업/채용", "취업/채용"),
      ("교내공모", "교내공모"),
      ("천장관", "천장관"),
      ("학사", "학사"),
      ("행사/소식", "행사/소식")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//tr//td[@class='left']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 5
          let titleIndex = index * 5 + 2
          let dateIndex = index * 5 + 3
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 한국예술종합학교 {
  
  var baseURL: String {
    return "http://www.karts.ac.kr"
  }
  
  var commonQueries: String {
    return "/nri/bbs/NuriBbsList.do?bbsId=BBSNURI_001&searchCondition=0"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&searchType=\(category.identifier.percentEncoding)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&pageIndex=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchKeyword=\(text.percentEncoding)"
  }
}
