//
//  숙명여자대학교.swift
//  UniTice
//
//  Created by Presto on 05/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 숙명여자대학교: UniversityModel {
    
    var name: String {
        return "숙명여자대학교"
    }
    
    var categories: [숙명여자대학교.Category] {
        return [
            ("58", "공지"),
            ("59", "학사"),
            ("60", "장학"),
            ("61", "입학"),
            ("134", "모집"),
            ("62", "IT")
        ]
    }
    
    func requestPosts(inCategory category: 숙명여자대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let numbers = doc.xpath("//tbody//tr//td[@class='num']")
                let titles = doc.xpath("//tbody//tr//td//p[@class='title']")
                let dates = doc.xpath("//tbody//tr//ul[@class='name']//li[@class='date']")
                let links = doc.xpath("//tbody//tr//td//p[@class='title']//a/@href")
                for (index, element) in links.enumerated() {
                    let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
                    let title = titles[index].text?.trimmed ?? "?"
                    let date = dates[index].text?.trimmed ?? "?"
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

extension 숙명여자대학교 {
    var baseURL: String {
        return "http://www.sookmyung.ac.kr"
    }
    
    var commonQueries: String {
        return "/bbs/sookmyungkr/66/artclList.do?srchColumn=sj"
    }
    
    func categoryQuery(_ category: 숙명여자대학교.Category) -> String {
        return "&bbsClSeq=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&srchWrd=\(text.percentEncoding)"
    }
}
