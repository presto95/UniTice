//
//  부산대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 부산대학교: UniversityModel {
    
    var name: String {
        return "부산대학교"
    }
    
    var categories: [부산대학교.Category] {
        return [
            ("MN095", "공지사항")
        ]
    }
    
    func pageURL(inCategory category: 부산대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(searchText)\(url4)\(page)"
    }
    
    func postURL(inCategory category: 부산대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 부산대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//table[@class='board-list-table']//tbody//td")
            let links = doc.xpath("//table[@class='board-list-table']//tbody//td[@class='subject']//a/@href")
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
            completion(posts)
        }
    }
}

extension 부산대학교 {
    private var url1: String {
        return "https://www.pusan.ac.kr/kor/CMS/Board/Board.do"
    }
    
    private var url2: String {
        return "?robot=Y&mCode="
    }
    
    private var url3: String {
        return "&searchID=title&searchKeyword="
    }
    
    private var url4: String {
        return "&mgr_seq=3&mode=list&page="
    }
}

//https://www.pusan.ac.kr/kor/CMS/Board/Board.do?robot=Y&mCode=MN095&searchID=title&searchKeyword=%EC%9E%A5%ED%95%99&mgr_seq=3&mode=list&page=1
