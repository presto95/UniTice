//
//  한국산업기술대학교.swift
//  UniTice
//
//  Created by Presto on 04/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 한국산업기술대학교: UniversityScrappable {
    
    var name: String {
        return "한국산업기술대학교"
    }
    
    var categories: [한국산업기술대학교.Category] {
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
    
    func requestPosts(inCategory category: 한국산업기술대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text), encoding: .eucKR) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let rows = doc.xpath("//tbody//tr//td")
            let links = doc.xpath("//tbody//tr//td[2]//a/@href")
            for (index, element) in links.enumerated() {
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
            completion(posts, nil)
        }
        }
    }
}

extension 한국산업기술대학교 {
    var baseURL: String {
        return "http://www.kpu.ac.kr"
    }
    
    var commonQueries: String {
        return "/front/boardlist.do?searchField=D.TITLE"
    }
    
    func categoryQuery(_ category: 한국산업기술대학교.Category) -> String {
        return "&bbsConfigFK=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&currentPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchValue=\(text.percentEncoding)"
    }
}
