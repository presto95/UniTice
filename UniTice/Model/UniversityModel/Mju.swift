//
//  Mju.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct Mju: UniversityModel {

    var name: String {
        return "명지대학교"
    }
    
    var categories: [Mju.Category] {
        return [
            ("11294", "일반공지"),
            ("11310", "성적/수강공지"),
            ("11318", "기타학사공지"),
            ("11327", "장학/학자금공지")
        ]
    }
    
    func pageURL(inCategory category: Mju.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\("list.jsp?boardId=")\(category.name)\(url2(ofCategory: category))\(page)"
    }
    
    func postURL(inCategory category: Mju.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: Mju.Category, inPage page: Int, completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: "")) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let links = doc.xpath("//table[@cellspacing='0']//a/@href")
            let rows = doc.xpath("//table[@cellspacing='0']//td")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 5
                let titleIndex = index * 5 + 1
                let dateIndex = index * 5 + 2
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

extension Mju {
    private var url1: String {
        return "http://www.mju.ac.kr/mbs/mjukr/jsp/board/"
    }
    
    private func url2(ofCategory category: Mju.Category) -> String {
        switch category.name {
        case "11294":
            return "&search=&column=&categoryDepth=&categoryId=0&mcategoryId=&boardType=01&listType=01&command=list&id=mjukr_050101000000&spage="
        case "11310":
            return "&search=&column=&categoryDepth=&categoryId=0&mcategoryId=&boardType=01&listType=01&command=list&id=mjukr_050103000000&spage="
        case "11318":
            return "&search=&column=&categoryDepth=&categoryId=0&mcategoryId=&boardType=01&listType=01&command=list&id=mjukr_050104000000&spage="
        case "11327":
            return "&search=&column=&categoryDepth=&categoryId=0&mcategoryId=&boardType=01&listType=01&command=list&id=mjukr_050106000000&spage="
        default:
            return ""
        }
    }
}
