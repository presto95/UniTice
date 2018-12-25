//
//  Dongduk.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct Dongduk: UniversityModel {
    
    var name: String {
        return "동덕여자대학교"
    }
    
    var categories: [Dongduk.Category] {
        return [
            ("ALL", "전체"),
            ("42", "교무처"),
            ("43", "학생처"),
            ("44", "사무처"),
            ("45", "기획처"),
            ("46", "예산관재처"),
            ("57", "입학처"),
            ("48", "춘강학술정보관"),
            ("56", "대학원"),
            ("47", "산학협력단"),
            ("50", "교무위원회"),
            ("49", "기타"),
            ("58", "총장실")
        ]
    }
    
    func pageURL(inCategory category: Dongduk.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(page)\(searchText)"
    }
    
    func postURL(inCategory category: Dongduk.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: Dongduk.Category, inPage page: Int, completion: @escaping (([Post]) -> Void)) {
        var posts = [Post]()
        guard let url = URL(string: self.pageURL(inCategory: category, inPage: page)) else { return }
        guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
        let numbers = doc.xpath("//tbody//td[@class='td-01']")
        let titles = doc.xpath("//tbody//td[@class='td-03']//h6[@class='subject']//a")
        let links = doc.xpath("//tbody//td[@class='td-03']//h6[@class='subject']//a/@href")
        let dates = doc.xpath("//tbody//td[@class='td-05']")
        for (index, element) in titles.enumerated() {
            let number = Int(numbers[index].text ?? "") ?? 0
            let title = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
            let link = links[index].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
            let date = dates[index].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
            let post = Post(number: number, title: title, date: date, link: link)
            posts.append(post)
        }
        completion(posts)
    }
}

extension Dongduk {
    private var url1: String {
        return "https://www.dongduk.ac.kr"
    }
    
    private var url2: String {
        return "/front/boardlist.do?bbsConfigFK=101&searchLowItem="
    }
    
    private var url3: String {
        return "&searchField=ALL&searchValue=&currentPage="
    }
}
