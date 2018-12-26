//
//  충북대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 충북대학교: UniversityModel {
    
    var name: String {
        return "충북대학교"
    }
    
    var categories: [충북대학교.Category] {
        return [
            ("112", "공지사항"),
            ("113", "학사/장학"),
            ("114", "행사/세미나공지")
        ]
    }
    
    func pageURL(inCategory category: 충북대학교.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(url2)\(page)\(url3)\(category.name)\(url4)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 충북대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 충북대학교.Category, inPage page: Int, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//table[@class='basic']//tbody[@class='tb']//td")
            let links = doc.xpath("//table[@class='basic']//tbody[@class='tb']//td[@class='subject']//a/@href")
            let divisor: Int
            switch category.name {
            case "112", "113":
                divisor = 6
            default:
                divisor = 4
            }
            for (index, element) in links.enumerated() {
                let numberIndex = index * divisor
                let titleIndex = index * divisor + 1
                let dateIndex = index * divisor + divisor - 1
                let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmed ?? "?"
                let date = rows[dateIndex].text?.trimmed ?? "?"
                var link = element.text?.trimmed ?? "?"
                link.removeFirst()
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 충북대학교 {
    private var url1: String {
        return "http://www.chungbuk.ac.kr/site/www"
    }
    
    private var url2: String {
        return "/boardList.do?key=698&searchType=TITLE&page="
    }
    
    private var url3: String {
        return "&boardSeq="
    }
    
    private var url4: String {
        return "&searchKeyword="
    }
}
