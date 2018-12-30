//
//  경희대학교.swift
//  UniTice
//
//  Created by Presto on 30/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 경희대학교: UniversityModel {
    
    var name: String {
        return "경희대학교"
    }
    
    var categories: [경희대학교.Category] {
        return [
            ("GENERAL", "일반"),
            ("UNDERGRADUATE", "학사"),
            ("SCHOLARSHIP", "장학"),
            ("SCHEDULE", "시간표 변경"),
            ("CREDIT", "교내학점교류"),
            ("EVENT", "행사")
        ]
    }
    
    func pageURL(inCategory category: 경희대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(baseURL)\(commonQueries)\(categoryQuery(category))\(pageQuery(page))\(searchQuery(searchText))"
    }
    
    func postURL(inCategory category: 경희대학교.Category, link: String) -> String {
        return "\(baseURL)\(link)"
    }
    
    func requestPosts(inCategory category: 경희대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let numbers = doc.xpath("//tbody//td[@class='col01']")
            let titles = doc.xpath("//tbody//p[@class='txt06']")
            let categories = doc.xpath("//tbody//td[@class='col02']//span[@class='txtBox01 common']")
            let dates = doc.xpath("//tbody//td[@class='col04']")
            let links = doc.xpath("//tbody//td[@class='col02']//a/@href")
            for (index, element) in links.enumerated() {
                let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
                let title = titles[index].text?.trimmed ?? "?"
                let category = categories[index].text?.trimmed ?? "?"
                let date = dates[index].text?.trimmed ?? "?"
                let link = element.text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: "\(date) | \(category)", link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 경희대학교 {
    private var baseURL: String {
        return "https://www.khu.ac.kr/kor/notice/"
    }
    
    private var commonQueries: String {
        return "list.do?"
    }
    
    private func categoryQuery(_ category: 경희대학교.Category) -> String {
        return "&category=\(category.name)"
    }
    
    private func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    private func searchQuery(_ text: String) -> String {
        return "&condition=title&keyword=\(text)"
    }
}
