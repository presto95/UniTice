//
//  고려대학교.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 고려대학교: UniversityModel {
    
    var name: String {
        return "고려대학교"
    }
    
    var categories: [고려대학교.Category] {
        return [
            ("NG", "일반공지"),
            ("E", "학사공지"),
            ("J", "장학공지")
        ]
    }
    
    func pageURL(inCategory category: 고려대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(page)\(url4)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 고려대학교.Category, link: String) -> String {
        return "\(url1)\(url5)\(url6)\(link)"
    }
    
    func requestPosts(inCategory category: 고려대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let titles = doc.xpath("//div[@class='summary']//a[@class='sbj']")
            let rows = doc.xpath("//div[@class='summary']//li")
            let links = doc.xpath("//div[@class='summary']//a/@href")
            for (index, element) in links.enumerated() {
                let dateIndex = index * 3 + 2
                let number = 1
                let title = titles[index].text?.trimmed ?? "?"
                let date = rows[dateIndex].text?.trimmed ?? "?"
                let link = element.text?.trimmed.filter { Int($0.description) != nil } ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 고려대학교 {
    private var url1: String {
        return "http://www.korea.ac.kr/cop/portalBoard/"
    }
    
    private var url2: String {
        return "portalBoardList.do?siteId=university&type="
    }
    
    private var url3: String {
        return "&page="
    }
    
    private var url4: String {
        return "&findType=SUBJECT&findWord="
    }
    
    private var url5: String {
        return "portalBoardView.do?siteId=university&type="
    }
    
    private var url6: String {
        return "&articleId="
    }
}

//http://www.korea.ac.kr/cop/portalBoard/portalBoardList.do?siteId=university&type=NG&page=1&findType=SUBJECT&findWord=2018
//일반공지
//http://www.korea.ac.kr/cop/portalBoard/portalBoardList.do?siteId=university&type=E
//학사공지
//http://www.korea.ac.kr/cop/portalBoard/portalBoardList.do?siteId=university&type=J
//장학금공지

