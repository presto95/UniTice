//
//  총신대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 총신대학교: UniversityScrappable {
    
    var name: String {
        return "총신대학교"
    }
    
    var categories: [총신대학교.Category] {
        return [
            ("54", "대학공지사항"),
            ("55", "신대원공지사항"),
            ("56", "대학원공지사항")
        ]
    }
    
    func requestPosts(inCategory category: 총신대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let rows = doc.xpath("//tbody//tr//td")
            let links = doc.xpath("//tbody//tr//td[@class='l']//a/@href")
            for (index, element) in links.enumerated() {
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
            completion(posts, nil)
        }
    }
}

extension 총신대학교 {
    var baseURL: String {
        return "http://www.chongshin.ac.kr/mbs/csu/jsp/board/"
    }
    
    var commonQueries: String {
        return "list.jsp?column=TITLE&id=csu_010501000000"
    }
    
    func categoryQuery(_ category: 총신대학교.Category) -> String {
        return "&boardId=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&spage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&search=\(text.percentEncoding)"
    }
}
