//
//  Mju.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 명지대학교: UniversityType {
  
  var name: String {
    return "명지대학교"
  }
  
  var categories: [Category] {
    return [
      ("11294", "일반공지"),
      ("11310", "성적/수강공지"),
      ("11318", "기타학사공지"),
      ("11327", "장학/학자금공지")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    let mjuLink = link.replacingOccurrences(of: "view", with: "view_mobile")
    let mjuBaseURL = baseURL.replacingOccurrences(of: "mjukr", with: "mjumob")
    let fullLink = "\(mjuBaseURL)\(mjuLink.percentEncoded)"
    return URL(string: fullLink)
  }
  
  func requestPosts(inCategory category: Category, inPage page: Int, searchText text: String) -> Observable<[Post]> {
    guard let url = pageURL(inCategory: category, inPage: page, searchText: text)
      else { return .empty() }
    return htmlParseManager.request(url, encoding: .utf8)
      .retry(2)
      .map { document in
        let links = document.xpath("//table[@cellspacing='0']//a/@href")
        let rows = document.xpath("//table[@cellspacing='0']//td")
        return links.enumerated().map { index, element in
          let numberIndex = index * 5
          let titleIndex = index * 5 + 1
          let dateIndex = index * 5 + 2
          let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
          let title = rows[titleIndex].text?.trimmed ?? "?"
          let date = rows[dateIndex].text?.trimmed ?? "?"
          let link = element.text?.trimmed ?? "?"
          return Post(number: number, title: title, date: date, link: link)
        }
      }
      .catchErrorJustReturn([])
  }
}

extension 명지대학교 {
  
  var baseURL: String {
    return "http://www.mju.ac.kr/mbs/mjukr/jsp/board/"
  }
  
  var commonQueries: String {
    return "list.jsp?qt=&column=TITLE&categoryDepth=&categoryId=0&mcategoryId=&boardType=01&listType=01&command=list"
  }
  
  func categoryQuery(_ category: Category) -> String {
    var result = "&boardId=\(category.identifier)"
    switch category.identifier {
    case "11294":
      result += "&id=mjumob_050101000000"
    case "11310":
      result += "&id=mjumob_050103000000"
    case "11318":
      result += "&id=mjumob_050104000000"
    case "11327":
      result += "&id=mjumob_050106000000"
    default:
      result += ""
    }
    return result
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&spage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&search=\(text.percentEncoded)"
  }
}
