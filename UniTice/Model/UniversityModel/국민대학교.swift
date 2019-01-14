//
//  국민대학교.swift
//  UniTice
//
//  Created by Presto on 05/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

struct 국민대학교: UniversityScrappable {
    
    var name: String {
        return "국민대학교"
    }
    
    var categories: [국민대학교.Category] {
        return [
            ("academic", "학사공지"),
            ("administration", "행정공지"),
            ("special_lecture", "특강공지"),
            ("scholarship", "장학공지"),
            ("social_service", "사회봉사"),
            ("event", "행사·활동·이벤트 공지"),
            ("student_council", "총학생회 공지"),
            ("prepare_graduation", "졸준위 공지")
        ]
    }
    
    func postURL(inCategory category: 국민대학교.Category, uri link: String) -> URL {
        guard let url = URL(string: "\(baseURL)\(categoryForPost(category))\(link.percentEncoding)") else {
            fatalError()
        }
        return url
    }
    
    func requestPosts(inCategory category: 국민대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let fixedCount = doc.xpath("//tbody//tr[@class='hot ']").count
            let numbers = doc.xpath("//tbody//tr//td[1]")
            let titles = doc.xpath("//tbody//tr//td[2]")
            let dates = doc.xpath("//tbody//tr//td[4]")
            let links = doc.xpath("//tbody//tr//td[2]//a/@href")
            for (index, element) in numbers.enumerated() {
                let number = Int(element.text?.trimmed ?? "") ?? 0
                let title = titles[index].text?.trimmed ?? "?"
                let link = links[index].text?.trimmed.dropFirst().description ?? "?"
                let date = number == 0 ? "" : dates[index - fixedCount].text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts, nil)
        }
    }
}

extension 국민대학교 {
    var baseURL: String {
        return "https://www.kookmin.ac.kr/site/ecampus/notice"
    }
    
    var commonQueries: String {
        return ""
    }
    
    func categoryQuery(_ category: 국민대학교.Category) -> String {
        return "/\(category.identifier)?"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&pn=\(page - 1)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&spart=subject&sc=&sq=\(text.percentEncoding)"
    }
    
    private func categoryForPost(_ category: 국민대학교.Category) -> String {
        return "/\(category.identifier)"
    }
}
