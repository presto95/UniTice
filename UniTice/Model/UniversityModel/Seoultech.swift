//
//  Seoultech.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct Seoultech: UniversityModel {
    
    var name: String {
        return "서울과학기술대학교"
    }
    
    var categories: [Seoultech.Category] {
        return [
            ("notice", "대학공지사항"),
            ("matters", "학사공지"),
            ("janghak", "장학공지")
        ]
    }
    
    func pageURL(inCategory category: Seoultech.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(category.name)\(url2(ofCategory: category))\(page)\(url3(ofCategory: category))\(searchText)"
    }
    
    func postURL(inCategory category: Seoultech.Category, link: String) -> String {
        return "\(url1)\(category.name)\(link)"
    }
    
    func requestPosts(inCategory category: Seoultech.Category, inPage page: Int, completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td")
            let links = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td[@class='tit']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 6
                let titleIndex = index * 6 + 1
                let dateIndex = index * 6 + 4
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

extension Seoultech {
    private var url1: String {
        return "http://www.seoultech.ac.kr/service/info/"
    }
    
    private func url2(ofCategory category: Seoultech.Category) -> String {
        switch category.name {
        case "notice":
            return "/?bidx=4691&bnum=4691&allboard=false&page="
        case "matters":
            return "/?bidx=6112&bnum=6112&allboard=true&page="
        case "janghak":
            return "/?bidx=5233&bnum=5233&allboard=true&page="
        default:
            return ""
        }
    }
    
    private func url3(ofCategory category: Seoultech.Category) -> String {
        switch category.name {
        case "notice":
            return "&size=9&searchtype=1&searchtext="
        case "matters":
            return "&size=5&searchtype=1&searchtext="
        case "janghak":
            return "&size=5&searchtype=1&searchtext="
        default:
            return ""
        }
    }
}
