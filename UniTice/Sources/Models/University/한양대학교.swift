//
//  한양대학교.swift
//  UniTice
//
//  Created by Presto on 10/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxSwift

struct 한양대학교: UniversityType {
  
  var name: String {
    return "한양대학교"
  }
  
  var categories: [Category] {
    return [
      ("1", "학사"),
      ("2", "입학"),
      ("3", "모집/채용"),
      ("4", "사회봉사"),
      ("5", "일반"),
      ("6", "산학/연구"),
      ("7", "행사"),
      ("8", "장학"),
      ("9", "학회/세미나")
    ]
  }
  
  func postURL(inCategory category: Category, uri link: String) -> URL? {
    guard let url = URL(string: "\(baseURL)\(commonQueries)\(messageIdForPost(link))") else {
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
        let titles = document.xpath("//tbody//tr//p[@class='title']")
        let dates = document.xpath("//tbody//tr//td//div[@class='notice-date']")
        let links = document.xpath("//tbody//tr//td//p[@class='title']//a/@href")
        return links.enumerated().map { index, element in
          let mappedTitles = titles[index].text?.trimmed.components(separatedBy: "\r\n").map { $0.trimmed }.filter { !$0.isEmpty }
          let number = mappedTitles?.first == "주요알림" ? 0 : 1
          let campus: String
          switch mappedTitles?.count {
          case 3:
            campus = mappedTitles?[1] ?? "?"
          case 2:
            campus = mappedTitles?.first ?? "?"
          default:
            campus = ""
          }
          let title = mappedTitles?.last ?? "?"
          let date = dates[index].text?.trimmed ?? "?"
          let link = element.text?.trimmed.filter { Int("\($0)") != nil } ?? "?"
          return Post(number: number, title: title, date: "\(campus) | \(date)", link: link)
        }
      }
      .catchErrorJustReturn([])
  }
}

extension 한양대학교 {
  
  var baseURL: String {
    return "https://www.hanyang.ac.kr/web/www/notice_all"
  }
  
  var commonQueries: String {
    return "?p_p_id=viewNotice_WAR_noticeportlet&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_count=1"
  }
  
  func categoryQuery(_ category: Category) -> String {
    return "&_viewNotice_WAR_noticeportlet_sCategoryId=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&_viewNotice_WAR_noticeportlet_sCurPage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&_viewNotice_WAR_noticeportlet_action=view&_viewNotice_WAR_noticeportlet_sKeyType=title&_viewNotice_WAR_noticeportlet_sKeyword=\(text.percentEncoded)"
  }
  
  private func messageIdForPost(_ text: String) -> String {
    return "&_viewNotice_WAR_noticeportlet_action=view_message&_viewNotice_WAR_noticeportlet_messageId=\(text)"
  }
}
