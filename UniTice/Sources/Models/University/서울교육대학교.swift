//
//  서울교육대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 서울교육대학교: UniversityScrappable {
  
  var name: String {
    return "서율교육대학교"
  }
  
  var categories: [Category] {
    return [
      ("notice", "공지사항"),
      ("graduate_notice", "학사공지"),
      ("janghak", "장학"),
      ("cheyong", "채용")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(categoryQuery(category))\(postNumber(link))") else {
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
        var posts: [Post] = []
        let numbers = document.xpath("//td[@class='td1']")
        let titles = document.xpath("//td[@class='td2']")
        let dates = document.xpath("//td[@class='td4']")
        let links = document.xpath("//tr/@onclick")
        links.enumerated().forEach { index, element in
          let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
          let title = titles[index].text?.trimmed ?? "?"
          let date = dates[index].text?.trimmed ?? "?"
          let link = element.text?.trimmed.filter { Int("\($0)") != nil } ?? "?"
          let post = Post(number: number, title: title, date: date, link: link)
          posts.append(post)
        }
        return posts
      }
      .catchErrorJustReturn([])
  }
}

extension 서울교육대학교 {
  
  var baseURL: String {
    return "http://portal.snue.ac.kr/enview/board"
  }
  
  var commonQueries: String {
    return "/list.brd?srchType=Subj"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&boardId=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&srchKey=\(text.percentEncoding)"
  }
  
  private var commonQueriesForPost: String {
    return "/read.brd?cmd=READ"
  }
  
  private func postNumber(_ number: String) -> String {
    return "&bltnNo=\(number)"
  }
}
