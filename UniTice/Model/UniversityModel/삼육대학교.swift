//
//  삼육대학교.swift
//  UniTice
//
//  Created by Presto on 05/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 삼육대학교: UniversityModel {
    
    var name: String {
        return "삼육대학교"
    }
    
    var categories: [삼육대학교.Category] {
        return [
            ("", "전체"),
            ("수업", "수업"),
            ("학적", "학적"),
            ("등록", "등록"),
            ("채플", "채플")
        ]
    }
    
    func postURL(inCategory category: 삼육대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: link) else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 삼육대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let numbers = doc.xpath("//tbody//tr//th")
                let titles = doc.xpath("//tbody//tr//td[@class='step2']//span[@class='tit']")
                let dates = doc.xpath("//tbody//tr//td[@class='step4']")
                let links = doc.xpath("//tbody//tr//td[@class='step2']//a/@href")
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

extension 삼육대학교 {
    var baseURL: String {
        return "https://new.syu.ac.kr"
    }
    
    var commonQueries: String {
        return "/academic/academic-notice?c=title"
    }
    
    func categoryQuery(_ category: 삼육대학교.Category) -> String {
        return "&t=\(category.identifier.percentEncoding)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&k=\(text.percentEncoding)"
    }
}
