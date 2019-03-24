//
//  국민대학교.swift
//  UniTice
//
//  Created by Presto on 05/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 국민대학교: UniversityType {
  
  var name: String {
    return "국민대학교"
  }
  
  var categories: [Category] {
    return [
      ("academic", "학사공지"),
      ("administration", "행정공지"),
      ("special_lecture", "특강공지"),
      ("scholarship", "장학공지"),
      ("social_service", "사회봉사"),
      ("event", "행사·활동·이벤트 공지"),
      ("student_council", "총학생회 공지"),
      ("prepare_graduation", "졸준위 공지")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(categoryForPost(category))\(link.percentEncoded)") else {
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
        let fixedCount = document.xpath("//tbody//tr[@class='hot ']").count
        let numbers = document.xpath("//tbody//tr//td[1]")
        let titles = document.xpath("//tbody//tr//td[2]")
        let dates = document.xpath("//tbody//tr//td[4]")
        let links = document.xpath("//tbody//tr//td[2]//a/@href")
        return numbers.enumerated().map { index, element in
          let number = Int(element.text?.trimmed ?? "") ?? 0
          let title = titles[index].text?.trimmed ?? "?"
          let link = links[index].text?.trimmed.dropFirst().description ?? "?"
          let date = number == 0 ? "" : dates[index - fixedCount].text?.trimmed ?? "?"
          return Post(number: number, title: title, date: date, link: link)
        }
      }
      .catchErrorJustReturn([])
  }
}

extension 국민대학교 {
  
  var baseURL: String {
    return "https://www.kookmin.ac.kr/site/ecampus/notice"
  }
  
  var commonQueries: String {
    return ""
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "/\(category.identifier)?"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&pn=\(page - 1)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&spart=subject&sc=&sq=\(text.percentEncoded)"
  }
  
  private func categoryForPost(_ category: Category) -> String {
    return "/\(category.identifier)"
  }
}
