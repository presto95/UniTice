//
//  Jnu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 전남대학교: UniversityModel {
    
    var name: String {
        return "전남대학교"
    }
    
    var categories: [전남대학교.Category] {
        return [
            ("0", "전체"),
            ("5", "학사안내"),
            ("6", "대학생활"),
            ("7", "취업정보"),
            ("8", "장학안내"),
            ("9", "행사안내"),
            ("10", "병무안내"),
            ("11", "공사안내"),
            ("12", "입찰공고"),
            ("13", "채용공고"),
            ("14", "IT뉴스"),
            ("15", "공모전"),
            ("16", "모집공고"),
            ("17", "학술연구"),
            ("842", "직원표창공개"),
            ("1367", "행정공고")
        ]
    }
    
    func pageURL(inCategory category: 전남대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(page)\(url4)\(searchText.percentEncoding)\(url5)"
    }
    
    func postURL(inCategory category: 전남대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 전남대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//table[@class='board_list']//tbody//td")
            let links = doc.xpath("//table[@class='board_list']//tbody//td[@class='title']//a/@href")
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

extension 전남대학교 {
    private var url1: String {
        return "http://www.jnu.ac.kr"
    }
    
    private var url2: String {
        return "/WebApp/web/HOM/COM/Board/board.aspx?boardID=5&bbsMode=list&cate="
    }
    
    private var url3: String {
        return "&page="
    }
    
    private var url4: String {
        return "&keyword="
    }
    
    private var url5: String {
        return "&searchTarget=title"
    }
}
