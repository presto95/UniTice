//
//  한국외국어대학교.swift
//  UniTice
//
//  Created by Presto on 31/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 한국외국어대학교: UniversityScrappable {
    
    var name: String {
        return "한국외국어대학교"
    }
    
    var categories: [한국외국어대학교.Category] {
        return [
            ("37079", "공지"),
            ("37080", "장학"),
            ("37082", "채용"),
            ("37083", "구매/공사실적")
        ]
    }
    
    func requestPosts(inCategory category: 한국외국어대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//tr//td[@class='title']//a/@href")
                let campuses = ["[공통]", "[서울]", "[글로벌]"]
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 6
                    let titleIndex = index * 6 + 1
                    let dateIndex = index * 6 + 3
                    let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                    var title = rows[titleIndex].text?.trimmed ?? "?"
                    for campus in campuses {
                        if let range = title.range(of: campus) {
                            title.removeSubrange(range)
                            title = title.trimmed
                            title = "\(campus) \(title)"
                            break
                        }
                    }
                    let date = rows[dateIndex].text?.trimmed ?? "?"
                    let link = element.text?.trimmed ?? "?"
                    let post = Post(number: number, title: title, date: date, link: link)
                    posts.append(post)
                }
                completion(posts, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension 한국외국어대학교 {
    var baseURL: String {
        return "http://builder.hufs.ac.kr/user/"
    }
    
    var commonQueries: String {
        return "indexSub.action?siteId=hufs&column=title"
    }
    
    func categoryQuery(_ category: 한국외국어대학교.Category) -> String {
        return "&codyMenuSeq=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&search=\(text.percentEncoding)"
    }
}
