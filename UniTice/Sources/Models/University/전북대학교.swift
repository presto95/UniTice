//
//  전북대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 전북대학교: UniversityType {
  
  var name: String {
    return "전북대학교"
  }
  
  var categories: [Category] {
    return [
      ("", "전체보기"),
      ("교육", "교육"),
      ("국제", "국제"),
      ("등록", "등록"),
      ("병무", "병무"),
      ("입학", "입학"),
      ("장학", "장학"),
      ("총무", "총무"),
      ("취업", "취업"),
      ("학사", "학사"),
      ("행사", "행사"),
      ("기타", "기타")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let numbers = document.xpath("//table[@class='ta_bo']//tbody//th[@scope='row']")
        let rows = document.xpath("//table[@class='ta_bo']//tbody//td")
        let links = document.xpath("//table[@class='ta_bo']//tbody//td[@class='left']//a/@href")
        links.enumerated().forEach { index, element in
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 4
          let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
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

extension 전북대학교 {
  
  var baseURL: String {
    return "https://www.jbnu.ac.kr/kor/"
  }
  
  var commonQueries: String {
    return "?menuID=139"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&category=\(category.identifier.percentEncoding)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&pno=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&sfv=subject&subject=\(text.percentEncoding)"
  }
}
