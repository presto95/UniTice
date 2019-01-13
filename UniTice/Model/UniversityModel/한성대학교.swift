//
//  한성대학교.swift
//  UniTice
//
//  Created by Presto on 02/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 한성대학교: UniversityScrappable {
    
    var name: String {
        return "한성대학교"
    }
    
    var categories: [한성대학교.Category] {
        return [
            ("cmty_01_01", "공지사항"),
            ("cmty_01_03", "학사공지"),
            ("552", "장학공지")
        ]
    }
    
    func pageURL(inCategory category: 한성대학교.Category, inPage page: Int, searchText text: String) -> URL {
        guard let url = URL(string: "\(baseURL)\(categoryQuery(category))\(commonQueries)\(pageQuery(page))\(searchQuery(text))") else {
            fatalError()
        }
        return url
    }
    
    func postURL(inCategory category: 경북대학교.Category, uri link: String) -> URL {
        guard let url = URL(string: link) else {
            fatalError()
        }
        return url
    }
    
    func requestPosts(inCategory category: 한성대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let rows = doc.xpath("//tbody//tr//td")
            let links = doc.xpath("//tbody//tr//td[@class='subject']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 6
                let titleIndex: Int
                if category.identifier == "552" {
                    titleIndex = index * 6 + 2
                } else {
                    titleIndex = index * 6 + 1
                }
                let dateIndex = index * 6 + 4
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

extension 한성대학교 {
    var baseURL: String {
        return "https://www.hansung.ac.kr/web/www/"
    }
    
    var commonQueries: String {
        return "?p_p_id=EXT_BBS&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=3&_EXT_BBS_struts_action=%2Fext%2Fbbs%2Fview&_EXT_BBS_sCategory=&_EXT_BBS_sKeyType=title"
    }
    
    func categoryQuery(_ category: 한성대학교.Category) -> String {
        return category.identifier
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&_EXT_BBS_curPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&_EXT_BBS_sKeyword=\(text.percentEncoding)"
    }
}
