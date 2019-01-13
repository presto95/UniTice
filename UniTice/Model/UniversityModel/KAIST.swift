//
//  KAIST.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct KAIST: UniversityScrappable {
    
    var name: String {
        return "KAIST"
    }
    
    var categories: [KAIST.Category] {
        return [
            ("kaist_event", "알림사항"),
            ("kaist_student", "학사공지"),
            ("kr_events", "행사 안내")
        ]
    }
    
    func requestPosts(inCategory category: KAIST.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let rows = doc.xpath("//tbody//tr//td")
            let links = doc.xpath("//tbody//tr//td[@class='title']//a/@href")
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

extension KAIST {
    var baseURL: String {
        return "https://www.kaist.ac.kr/_prog/_board/"
    }
    
    var commonQueries: String {
        return "index.php?"
    }
    
    func categoryQuery(_ category: KAIST.Category) -> String {
        return "&code=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&GotoPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&skey=title&sval=\(text.percentEncoding)"
    }
}
