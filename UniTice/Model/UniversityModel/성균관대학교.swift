//
//  성균관대학교.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 성균관대학교: UniversityModel {
    
    var name: String {
        return "성균관대학교"
    }
    
    var categories: [성균관대학교.Category] {
        return [
            ("01", "전체"),
            ("02", "학사"),
            ("03", "입학"),
            ("04", "취업"),
            ("05", "채용/모집"),
            ("06", "장학"),
            ("07", "행사/세미나"),
            ("07", "일반")
        ]
    }
    
    func pageURL(inCategory category: 성균관대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2(category))\(url3)\(url4)\((page - 1) * 10)\(url5)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 성균관대학교.Category, link: String) -> String {
        return "\(url1)\(url2(category))\(link)"
    }
    
    func requestPosts(inCategory category: 성균관대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let numbers = doc.xpath("//table[@class='board_list']//tbody//td[1]")
            let titles = doc.xpath("//table[@class='board_list']//tbody//td[@class='left']//a")
            let dates = doc.xpath("//table[@class='board_list']//tbody//td[3]")
            let links = doc.xpath("//table[@class='board_list']//tbody//td[@class='left']//a/@href")
            for (index, element) in links.enumerated() {
                let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
                let title = titles[index].text?.trimmed ?? "?"
                let date = dates[index].text?.trimmed ?? "?"
                let link = element.text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 성균관대학교 {
    private var url1: String {
        return "https://www.skku.edu/skku/campus/skk_comm/"
    }
    
    private func url2(_ category: 성균관대학교.Category) -> String {
        return "notice\(category.name).do"
    }
    
    private var url3: String {
        return "?mode=list&srSearchKey=article_title"
    }
    
    private var url4: String {
        return "&article.offset="
    }
    
    private var url5: String {
        return "&srSearchVal="
    }
}
