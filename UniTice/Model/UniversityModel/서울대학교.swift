//
//  Snu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 서울대학교: UniversityModel {
    
    var name: String {
        return "서울대학교"
    }
    
    var categories: [서울대학교.Category] {
        return [
            ("notice", "일반공지")
        ]
    }
    
    func pageURL(inCategory category: 서울대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(category.name)\(url2)\(page)\(url3)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 서울대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 서울대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//table[@class='table01n_list']//tbody//td")
            let links = doc.xpath("//table[@class='table01n_list']//tbody//a/@href")
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
            completion(posts)
        }
    }
}

extension 서울대학교 {
    private var url1: String {
        return "http://www.snu.ac.kr/"
    }
    
    private var url2: String {
        return "?page="
    }
    
    private var url3: String {
        return "&bt=t&bq="
    }
}
