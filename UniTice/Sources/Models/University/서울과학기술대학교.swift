//
//  Seoultech.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 서울과학기술대학교: UniversityScrappable {
  
  var name: String {
    return "서울과학기술대학교"
  }
  
  var categories: [Category] {
    return [
      ("notice", "대학공지사항"),
      ("matters", "학사공지"),
      ("janghak", "장학공지"),
      ("graduate", "대학원공지"),
      ("bid", "대학입찰"),
      ("recruit", "채용정보"),
      ("committee", "등록금심의위원회"),
      ("budgetcomm", "재정위원회")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(category.identifier)\(link.percentEncoding)") else {
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
        let rows = document.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td")
        let links = document.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td[@class='tit']//a/@href")
        links.enumerated().forEach { index, element in
          let numberIndex = index * 6
          let titleIndex = index * 6 + 1
          let dateIndex = index * 6 + 4
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

extension 서울과학기술대학교 {
  
  var baseURL: String {
    return "http://www.seoultech.ac.kr/service/info/"
  }
  
  var commonQueries: String {
    return ""
  }
  
  func categoryQuery(_ category: Category) -> String {
    var result = category.identifier
    switch category.identifier {
    case "notice":
      result += "/?bidx=4691&bnum=4691&allboard=false&size=9"
    case "matters":
      result += "/?bidx=6112&bnum=6112&allboard=true&size=5"
    case "janghak":
      result += "/?bidx=5233&bnum=5233&allboard=true&size=5"
    case "graduate":
      result += "/?bidx=56589&bnum=56589&allboard=false&size=9"
    case "bid":
      result += "/?bidx=4694&bnum=4694&allboard=true&size=9"
    case "recruit":
      result += "/?bidx=3601&bnum=3601&allboard=false&size=10"
    case "committee":
      result += "/?bidx=3606&bnum=3606&allboard=false&size=15"
    case "budgetcomm":
      result += "/?bidx=56473&bnum=56473&allboard=false&size=15"
    default:
      result += ""
    }
    return result
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&page=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchtype=1&searchtext=\(text.percentEncoding)"
  }
}
