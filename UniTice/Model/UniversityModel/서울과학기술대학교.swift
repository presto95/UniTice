//
//  Seoultech.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct 서울과학기술대학교: UniversityScrappable {
    
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
    
    func postURL(inCategory category: 서울과학기술대학교.Category, uri link: String) -> URL {
        guard let url = URL(string: "\(baseURL)\(category.identifier)\(link.percentEncoding)") else {
            fatalError()
        }
        return url
    }
    
    func requestPosts(inCategory category: 서울과학기술대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let rows = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td")
            let links = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td[@class='tit']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 6
                let titleIndex = index * 6 + 1
                let dateIndex = index * 6 + 4
                let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmed ?? "?"
                let date = rows[dateIndex].text?.trimmed ?? "?"
                let link = element.text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts, nil)
        }
    }
}

extension 서울과학기술대학교 {
    var baseURL: String {
        return "http://www.seoultech.ac.kr/service/info/"
    }
    
    var commonQueries: String {
        return ""
    }
    
    func categoryQuery(_ category: 서울과학기술대학교.Category) -> String {
        var result = category.identifier
        switch category.identifier {
        case "notice":
            result += "/?bidx=4691&bnum=4691&allboard=false&size=9"
        case "matters":
            result += "/?bidx=6112&bnum=6112&allboard=true&size=5"
        case "janghak":
            result += "/?bidx=5233&bnum=5233&allboard=true&size=5"
        case "graduate":
            result += "/?bidx=56589&bnum=56589&allboard=false&size=9"
        case "bid":
            result += "/?bidx=4694&bnum=4694&allboard=true&size=9"
        case "recruit":
            result += "/?bidx=3601&bnum=3601&allboard=false&size=10"
        case "committee":
            result += "/?bidx=3606&bnum=3606&allboard=false&size=15"
        case "budgetcomm":
            result += "/?bidx=56473&bnum=56473&allboard=false&size=15"
        default:
            result += ""
        }
        return result
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchtype=1&searchtext=\(text.percentEncoding)"
    }
}
