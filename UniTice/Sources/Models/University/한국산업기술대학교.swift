//
//  한국산업기술대학교.swift
//  UniTice
//
//  Created by Presto on 04/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 한국산업기술대학교: UniversityType {
  
  var name: String {
    return "한국산업기술대학교"
  }
  
  var categories: [Category] {
    return [
      ("1", "학사공지"),
      ("494", "장학공지"),
      ("339", "취업공지"),
      ("357", "일반공지"),
      ("460", "학칙개정공고"),
      ("2", "입찰공고"),
      ("3", "행사"),
      ("576", "평생교육원공지")
    ]
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .eucKR)
      .retry(2)
      .map { document in
        var posts: [Post] = []
        let rows = document.xpath("//tbody//tr//td")
        let links = document.xpath("//tbody//tr//td[2]//a/@href")
        links.enumerated().forEach { index, element in
          let (numberIndex, titleIndex, dateIndex): (Int, Int, Int)
          if category.identifier == "494" {
            numberIndex = index * 7
            titleIndex = index * 7 + 1
            dateIndex = index * 7 + 5
          } else {
            numberIndex = index * 6
            titleIndex = index * 6 + 1
            dateIndex = index * 6 + 4
          }
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

extension 한국산업기술대학교 {
  
  var baseURL: String {
    return "http://www.kpu.ac.kr"
  }
  
  var commonQueries: String {
    return "/front/boardlist.do?searchField=D.TITLE"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&bbsConfigFK=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&currentPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchValue=\(text.percentEncoding)"
  }
}
