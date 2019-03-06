//
//  경희대학교.swift
//  UniTice
//
//  Created by Presto on 30/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 경희대학교: UniversityType {
  
  var name: String {
    return "경희대학교"
  }
  
  var categories: [Category] {
    return [
      ("GENERAL", "일반"),
      ("UNDERGRADUATE", "학사"),
      ("SCHOLARSHIP", "장학"),
      ("SCHEDULE", "시간표 변경"),
      ("CREDIT", "교내학점교류"),
      ("EVENT", "행사")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts = [Post]()
        let numbers = document.xpath("//tbody//td[@class='col01']")
        let titles = document.xpath("//tbody//p[@class='txt06']")
        let categories = doc.xpath("//tbody//td[@class='col02']//span[@class='txtBox01 common']")
        let dates = document.xpath("//tbody//td[@class='col04']")
        let links = document.xpath("//tbody//td[@class='col02']//a/@href")
        links.enumerated().forEach { index, element in
          let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
          let title = titles[index].text?.trimmed ?? "?"
          let category = categories[index].text?.trimmed ?? "?"
          let date = dates[index].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          let post = Post(number: number, title: title, date: "\(date) | \(category)", link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 경희대학교 {
  
  var baseURL: String {
    return "https://www.khu.ac.kr/kor/notice/"
  }
  
  var commonQueries: String {
    return "list.do?"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&category=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&condition=title&keyword=\(text.percentEncoding)"
  }
}
