//
//  경상대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct 경상대학교: UniversityScrappable {
  
  var name: String {
    return "경상대학교"
  }
  
  var categories: [경상대학교.Category] {
    return [
      ("10026", "HOT NEWS"),
      ("10027", "학사공지"),
      ("10303", "기관공지"),
      ("10028", "학술/행사"),
      ("10030", "입찰정보"),
      ("10029", "보도자료"),
      ("11531", "HOT ISSUE"),
      ("10579", "교육소식")
    ]
  }
  
  func requestPosts(inCategory category: 경상대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
    HTMLParseService.shared.request(pageURL(inCategory: category, inPage: page, searchText: text), encoding: .eucKR) { doc, error in
      guard let doc = doc else {
        completion(nil, error)
        return
      }
      var posts = [Post]()
      let rows = doc.xpath("//tbody[@class='tb']//td")
      let links = doc.xpath("//tbody[@class='tb']//td[@class='subject']//a[1]/@href")
      let realRows = Array(rows.dropFirst(rows.count % links.count))
      let divisor: Int
      let dateIndexIncrement: Int
      switch category.identifier {
      case "10026":
        divisor = 7
        dateIndexIncrement = 4
      case "10027", "10029", "11531", "10579":
        divisor = 5
        dateIndexIncrement = 3
      default:
        divisor = 6
        dateIndexIncrement = 4
      }
      for (index, element) in links.enumerated() {
        let numberIndex = index * divisor
        let titleIndex = index * divisor + 1
        let dateIndex = index * divisor + dateIndexIncrement
        let number = Int(realRows[numberIndex].text?.trimmed ?? "") ?? 0
        let title = realRows[titleIndex].text?.trimmed ?? "?"
        let date = realRows[dateIndex].text?.trimmed ?? "?"
        let link = element.text?.trimmed ?? "?"
        let post = Post(number: number, title: title, date: date, link: link)
        posts.append(post)
      }
      completion(posts, nil)
    }
  }
}

extension 경상대학교 {
  var baseURL: String {
    return "https://www.gnu.ac.kr/program/multipleboard/"
  }
  
  var commonQueries: String {
    return "BoardList.jsp?"
  }
  
  func categoryQuery(_ category: 경상대학교.Category) -> String {
    return "groupNo=\(category.identifier)"
  }
  
  func pageQuery(_ page: Int) -> String {
    return "&cpage=\(page)"
  }
  
  func searchQuery(_ text: String) -> String {
    return "&searchType=&category=&type=&searchString=\(text.percentEncoding)"
  }
}
