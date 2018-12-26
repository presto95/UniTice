//
//  제주대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 제주대학교: UniversityModel {
    
    var name: String {
        return "제주대학교"
    }
    
    var categories: [제주대학교.Category] {
        return [
            ("notice", "JNU소식"),
            ("degree", "학사안내"),
            ("exchange", "국내교류수학안내"),
            ("recruit", "채용안내"),
            ("scholarship", "장학안내"),
            ("event", "알림및행사안내"),
            ("outEvent", "외부기관행사"),
            ("service", "봉사안내")
        ]
    }
    
    func pageURL(inCategory category: 제주대학교.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(category.name)\(url2)\(page)\(url3)\(searchText)"
    }
    
    func postURL(inCategory category: 제주대학교.Category, link: String) -> String {
        return link
    }
    
    func requestPosts(inCategory category: 제주대학교.Category, inPage page: Int, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//table[@class='table border_top_blue list']//tbody//td")
            let links = doc.xpath("//table[@class='table border_top_blue list']//tbody//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 5
                let titleIndex = index * 5 + 1
                let dateIndex = index * 5 + 3
                let number = Int(rows[numberIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
                let date = rows[dateIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
                let link = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 제주대학교 {
    private var url1: String {
        return "http://www.jejunu.ac.kr/ara/"
    }
    
    private var url2: String {
        return "?page="
    }
    
    private var url3: String {
        return "&s%5Bs%5D=subject&s%5Bq%5D="
    }
}

//http://www.jejunu.ac.kr/ara/degree?page=1&s%5Bs%5D=subject&s%5Bq%5D=asfd
//카테고리 / 페이지 / 검색키워드(마지막)
