//
//  경북대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 경북대학교: UniversityModel {
    
    var name: String {
        return "경북대학교"
    }
    
    var categories: [경북대학교.Category] {
        return [
            ("1", "공지사항"),
            ("11", "행사"),
            ("12", "교외행사"),
            ("8", "경북대채용")
        ]
    }
    
    func pageURL(inCategory category: 경북대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2)\(page)\(url3)\(category.name)\(url4(searchText: searchText.percentEncoding))"
    }
    
    func postURL(inCategory category: 경북대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 경북대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//div[@class='board_list']//tbody//td")
            let links = doc.xpath("//div[@class='board_list']//tbody//td[@class='subject']//a/@href")
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
            completion(posts)
        }
    }
}

extension 경북대학교 {
    private var url1: String {
        return "https://www.knu.ac.kr"
    }
    
    private var url2: String {
        return "/wbbs/wbbs/bbs/btin/list.action?btin.page="
    }
    
    private var url3: String {
        return "&bbs_cde="
    }
    
    private func url4(searchText: String) -> String {
        return "&input_search_type=search_subject&btin.search_type=search_subject&input_search_text=\(searchText)&btin.search_text=\(searchText)"
    }
}
