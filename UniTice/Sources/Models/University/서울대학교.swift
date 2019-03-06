//
//  Snu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 서울대학교: UniversityType {
  
  var name: String {
    return "서울대학교"
  }
  
  var categories: [Category] {
    return [
      ("notice", "일반공지")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//table[@class='table01n_list']//tbody//td")
        let links = document.xpath("//table[@class='table01n_list']//tbody//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 4
          let titleIndex = index * 4 + 1
          let dateIndex = index * 4 + 2
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

extension 서울대학교 {
  
  var baseURL: String {
    return "http://www.snu.ac.kr/"
  }
  
  var commonQueries: String {
    return ""
  }
  
  func categoryQuery(_ category: Category) -> String {
    return category.identifier
  }
  
  func pageQuery(_ page: Int) -> String {
    return "?page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&bt=t&bq=\(text.percentEncoding)"
  }
}
