//
//  경성대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 경성대학교: UniversityScrappable {
    
    var name: String {
        return "경성대학교"
    }
    
    var categories: [경성대학교.Category] {
        return [
            ("MN093", "학사"),
            ("MN094", "장학"),
            ("MN095", "취업"),
            ("MN091", "교내"),
            ("MN092", "교외"),
            ("MN0006", "봉사")
        ]
    }
    
    func requestPosts(inCategory category: 경성대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//tr//td[@class='subject']//a/@href")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 5
                    let titleIndex = index * 5 + 1
                    let dateIndex = index * 5 + 3
                    let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                    let title = rows[titleIndex].text?.trimmed ?? "?"
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

extension 경성대학교 {
    var baseURL: String {
        return "http://kscms.ks.ac.kr/kor/CMS/Board/Board.do"
    }
    
    var commonQueries: String {
        return "?searchID=sch001"
    }
    
    func categoryQuery(_ category: 경성대학교.Category) -> String {
        return "&mCode=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchKeyword=\(text.percentEncoding)"
    }
}
