//
//  세종대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 세종대학교: UniversityModel {
    
    var name: String {
        return "세종대학교"
    }
    
    var categories: [세종대학교.Category] {
        return [
            ("333", "공지"),
            ("335", "학사"),
            ("674", "국제교류"),
            ("337", "취업/장학"),
            ("339", "교내모집")
        ]
    }
    
    func requestPosts(inCategory category: 세종대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
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

extension 세종대학교 {
    var baseURL: String {
        return "http://board.sejong.ac.kr"
    }
    
    var commonQueries: String {
        return "/boardlist.do?searchField=D.TITLE"
    }
    
    func categoryQuery(_ category: 세종대학교.Category) -> String {
        return "&bbsConfigFK=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&currentPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchValue=\(text.percentEncoding)"
    }
}
