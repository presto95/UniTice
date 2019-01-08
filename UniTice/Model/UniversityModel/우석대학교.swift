//
//  우석대학교.swift
//  UniTice
//
//  Created by Presto on 08/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 우석대학교: UniversityModel {
    
    var name: String {
        return "우석대학교"
    }
    
    var categories: [우석대학교.Category] {
        return [
            ("B0199", "학사공지"),
            ("B0022", "일반공지"),
            ("B0062", "행사 및 알림"),
            ("B0022", "자유게시판")
        ]
    }
    
    func requestPosts(inCategory category: 우석대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//tr//td//a/@href")
                for (index, element) in links.enumerated() {
                    let multiplier = category.identifier == "B0022" ? 7 : 6
                    let numberIndex = index * multiplier
                    let titleIndex = index * multiplier + multiplier - 5
                    let dateIndex = index * multiplier + multiplier - 2
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

extension 우석대학교 {
    var baseURL: String {
        return "https://www.woosuk.ac.kr"
    }
    
    var commonQueries: String {
        return "/boardList.do?paramField=title"
    }
    
    func categoryQuery(_ category: 우석대학교.Category) -> String {
        return "&bcode=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&PF=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&paramKeyword=\(text.percentEncoding)"
    }
}
