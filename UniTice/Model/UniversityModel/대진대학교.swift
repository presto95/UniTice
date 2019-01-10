//
//  대진대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 대진대학교: UniversityScrappable {
    
    var name: String {
        return "대진대학교"
    }
    
    var categories: [대진대학교.Category] {
        return [
            ("2", "일반"),
            ("1", "학사"),
            ("4", "장학"),
            ("5", "취업"),
            ("3", "입찰")
        ]
    }
    
    func requestPosts(inCategory category: 대진대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .eucKR)
                let rows = doc.xpath("//html//body//div//div//div[2]//tbody//tr//td")
                let links = doc.xpath("//html//body//div//div//div[2]//tbody//tr//td//a/@href")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 4
                    let titleIndex = index * 4 + 1
                    let dateIndex = index * 4 + 2
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

extension 대진대학교 {
    var baseURL: String {
        return "http://www.daejin.ac.kr"
    }
    
    var commonQueries: String {
        return "/front/unitedboardlist.do?type=N&searchField=TITLE"
    }
    
    func categoryQuery(_ category: 대진대학교.Category) -> String {
        return "&bbsConfigFK=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&currentPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchValue=\(text.percentEncoding)"
    }
}
