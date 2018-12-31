//
//  동국대학교.swift
//  UniTice
//
//  Created by Presto on 31/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 동국대학교: UniversityModel {
    
    var name: String {
        return "동국대학교"
    }
    
    var categories: [동국대학교.Category] {
        return [
            ("3646", "일반공지"),
            ("3638", "학사공지"),
            ("3654", "입시공지"),
            ("3662", "장학공지"),
            ("9457435", "국제공지"),
            ("11533472", "학술/행사공지")
        ]
    }
    
    func requestPosts(inCategory category: 동국대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//td")
                let links = doc.xpath("//tbody//td[@class='title']//a/@href")
                for (index, element) in links.enumerated() {
                    let numberIndex = index
                    let titleIndex = index * 7 + 1
                    let dateIndex = index * 7 + 3
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

extension 동국대학교 {
    var baseURL: String {
        return "https://www.dongguk.edu/mbs/kr/jsp/board/"
    }
    
    var commonQueries: String {
        return "list.jsp?column=TITLE&mcategoryId=0&boardType=01&listType=01&command=list"
    }
    
    func categoryQuery(_ category: 동국대학교.Category) -> String {
        return "&boardId=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&spage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&search=\(text.percentEncoding)"
    }
}
