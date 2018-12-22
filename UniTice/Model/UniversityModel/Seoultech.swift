//
//  Seoultech.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation
import Kanna

struct Seoultech {
    
    enum Category: String, CaseIterable {
        
        case notice
        
        case matters
        
        case janghak
        
        var description: String {
            switch self {
            case .notice:
                return "대학공지사항"
            case .matters:
                return "학사공지"
            case .janghak:
                return "장학공지"
            }
        }
    }
    
    let categories = Category.allCases
    
    private let url1: String = "http://www.seoultech.ac.kr/service/info/"
    
    private func url2(ofCategory category: Category) -> String {
        switch category {
        case .notice:
            return "/?bidx=4691&bnum=4691&allboard=false&page="
        case .matters:
            return "/?bidx=6112&bnum=6112&allboard=true&page="
        case .janghak:
            return "/?bidx=5233&bnum=5233&allboard=true&page="
        }
    }
    
    private func url3(ofCategory category: Category) -> String {
        switch category {
        case .notice:
            return "&size=9&searchtype=1&searchtext="
        case .matters:
            return "&size=5&searchtype=1&searchtext="
        case .janghak:
            return "&size=5&searchtype=1&searchtext="
        }
    }
    
    func url(inCategory category: Category, inPage index: Int, searchText: String = "") -> String {
        return "\(url1)\(category.rawValue)\(url2(ofCategory: category))\(index)\(url3(ofCategory: category))\(searchText)"
    }
    
    func requestPostList(inCategory category: Category, inPage page: Int, completionHandler: @escaping ([Post]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var posts = [Post]()
            guard let url = URL(string: self.url(inCategory: category, inPage: page)) else { return }
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
                let post = Post(number: number, category: "", title: title, date: date, link: link)
                posts.append(post)
            }
            completionHandler(posts)
        }
    }
}
