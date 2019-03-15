//
//  광운대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 광운대학교: UniversityType {
  
  var name: String {
    return "광운대학교"
  }
  
  var categories: [Category] {
    return [
      ("5", "일반"),
      ("6", "학사"),
      ("16", "학생"),
      ("17", "봉사"),
      ("18", "등록/장학"),
      ("19", "입학"),
      ("20", "시설"),
      ("21", "병무"),
      ("22", "외부")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        var descriptions = self.categories.map { "[\($0.description)]" }
        descriptions.append(contentsOf: ["신규게시글", "Attachment"])
        let numbers = document.xpath("//div[@class='board-list-box']//li//span[1]")
        let titles = document.xpath("//div[@class='board-list-box']//div[@class='board-text']//a")
        let dates = document.xpath("//div[@class='board-list-box']//p[@class='info']")
        let links = document.xpath("//div[@class='board-list-box']//div[@class='board-text']//a/@href")
        links.enumerated().forEach { index, element in
          let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
          var tempTitle = titles[index].text?.trimmed ?? "?"
          for description in descriptions {
            if let range = tempTitle.range(of: description) {
              tempTitle.removeSubrange(range)
            }
          }
          let title = tempTitle.trimmed
          let date = dates[index].text?.trimmed.components(separatedBy: "|")[1].trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 광운대학교 {
  
  var baseURL: String {
    return "https://www.kw.ac.kr/ko/life/notice.do"
  }
  
  var commonQueries: String {
    return "?mode=list"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&srCategoryId1=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&article.offset=\(10 * (page - 1))"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&srSearchKey=article_title&srSearchVal=\(text.percentEncoded)"
  }
}
