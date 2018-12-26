//
//  Seoultech.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 서울과학기술대학교: UniversityModel {
    
    var name: String {
        return "서울과학기술대학교"
    }
    
    var categories: [서울과학기술대학교.Category] {
        return [
            ("notice", "대학공지사항"),
            ("matters", "학사공지"),
            ("janghak", "장학공지"),
            ("graduate", "대학원공지"),
            ("bid", "대학입찰"),
            ("recruit", "채용정보"),
            ("committee", "등록금심의위원회"),
            ("budgetcomm", "재정위원회")
        ]
    }
    
    func pageURL(inCategory category: 서울과학기술대학교.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(category.name)\(url2(ofCategory: category))\(page)\(url3(ofCategory: category))\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 서울과학기술대학교.Category, link: String) -> String {
        return "\(url1)\(category.name)\(link)"
    }
    
    func requestPosts(inCategory category: 서울과학기술대학교.Category, inPage page: Int, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
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

extension 서울과학기술대학교 {
    private var url1: String {
        return "http://www.seoultech.ac.kr/service/info/"
    }
    
    private func url2(ofCategory category: 서울과학기술대학교.Category) -> String {
        switch category.name {
        case "notice":
            return "/?bidx=4691&bnum=4691&allboard=false&page="
        case "matters":
            return "/?bidx=6112&bnum=6112&allboard=true&page="
        case "janghak":
            return "/?bidx=5233&bnum=5233&allboard=true&page="
        case "graduate":
            return "/?bidx=56589&bnum=56589&allboard=false&page="
        case "bid":
            return "/?bidx=4694&bnum=4694&allboard=true&page="
        case "recruit":
            return "/?bidx=3601&bnum=3601&allboard=false&page="
        case "committee":
            return "/?bidx=3606&bnum=3606&allboard=false&page="
        case "budgetcomm":
            return "/?bidx=56473&bnum=56473&allboard=false&page="
        default:
            return ""
        }
    }
    
    private func url3(ofCategory category: 서울과학기술대학교.Category) -> String {
        switch category.name {
        case "notice":
            return "&size=9&searchtype=1&searchtext="
        case "matters":
            return "&size=5&searchtype=1&searchtext="
        case "janghak":
            return "&size=5&searchtype=1&searchtext="
        case "graduate":
            return "&size=9&searchtype=1&searchtext="
        case "bid":
            return "&size=9&searchtype=1&searchtext="
        case "recruit":
            return "&size=10&searchtype=1&searchtext="
        case "committee":
            return "&size=15&searchtype=1&searchtext="
        case "budgetcomm":
            return "&size=15&searchtype=1&searchtext="
        default:
            return ""
        }
    }
}
