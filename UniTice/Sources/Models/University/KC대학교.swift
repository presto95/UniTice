//
//  KC대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct KC대학교: UniversityScrappable {
  
  var name: String {
    return "KC대학교"
  }
  
  var categories: [Category] {
    return [
      ("BC0701", "KC공지"),
      ("BC0702", "학사"),
      ("EC0101", "입학"),
      ("BC0703", "장학"),
      ("GC0101", "비교과행사"),
      ("BC0704", "입찰공고")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL {
    switch category.identifier {
    case "EC0101":
      guard let url = URL(string: link.percentEncoding) else {
        fatalError()
      }
      return url
    default:
      guard let url = URL(string: "\(baseURL)\(link.percentEncoding)") else {
        fatalError()
      }
      return url
    }
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//td[@class='b_sub']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 6
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 3
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

extension KC대학교 {
  
  var baseURL: String {
    return "http://kcu.ac.kr"
  }
  
  var commonQueries: String {
    return ""
  }
  
  func categoryQuery(_ category: Category) -> String {
    var result = ""
    switch category.identifier {
    case "EC0101":
      result += "/kcui"
    case "GC0101":
      result += "/kcug"
    default:
      result += "/kcua"
    }
    return result + "/boardList?menuCode=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&thisPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchCode=2&searchKey=\(text.percentEncoding)"
  }
}
