//
//  세한대학교.swift
//  UniTice
//
//  Created by Presto on 08/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 세한대학교: UniversityModel {
    
    var name: String {
        return "세한대학교"
    }
    
    var categories: [세한대학교.Category] {
        return [
            ("notiList", "일반공지"),
            ("acnotiList", "학사공지"),
            ("newsList", "새소식"),
            ("coverList", "보도자료"),
            ("athlList", "체육부소식"),
            ("infoList", "정보게시판")
        ]
    }
    
    func requestPosts(inCategory category: 세한대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//tr//td//a/@href")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 6
                    let titleIndex = index * 6 + 1
                    let dateIndex = index * 6 + 4
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

extension 세한대학교 {
    var baseURL: String {
        return "http://www.sehan.ac.kr"
    }
    
    var commonQueries: String {
        return "/main/board/"
    }
    
    func categoryQuery(_ category: 세한대학교.Category) -> String {
        return "\(category.identifier).do?"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&pageNo=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchType=title&searchText=\(text.percentEncoding)"
    }
}
