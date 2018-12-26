//
//  충남대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 충남대학교: UniversityModel {
    
    var name: String {
        return "충남대학교"
    }
    
    var categories: [충남대학교.Category] {
        return [
            ("0701", "새소식"),
            ("0702", "학사정보"),
            ("0704", "교육정보"),
            ("0709", "사업단 창업ㆍ교육"),
            ("0705", "채용/초빙")
        ]
    }
    
    func pageURL(inCategory category: 충남대학교.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(category.name)\(url4)\(searchText.percentEncoding)\(url5)\(page)"
    }
    
    func postURL(inCategory category: 충남대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 충남대학교.Category, inPage page: Int, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//div[@class='board_list']//tbody//td")
            let links = doc.xpath("//div[@class='board_list']//tbody//td[@class='title']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 6
                let titleIndex = index * 6 + 1
                let dateIndex = index * 6 + 3
                let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmed ?? "?"
                let date = rows[dateIndex].text?.trimmed ?? "?"
                var realLink = element.text?.trimmed ?? "?"
                realLink.removeFirst()
                let post = Post(number: number, title: title, date: date, link: realLink)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 충남대학교 {
    private var url1: String {
        return "http://plus.cnu.ac.kr/_prog/_board/"
    }
    
    private var url2: String {
        return "?site_dvs_cd=kr&menu_dvs_cd="
    }
    
    private var url3: String {
        return "&code=sub07_"
    }
    
    private var url4: String {
        return "&skey=title&sval="
    }
    
    private var url5: String {
        return "&site_dvs=&ntt_tag=&GotoPage="
    }
}
