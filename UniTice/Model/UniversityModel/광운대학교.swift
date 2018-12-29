//
//  광운대학교.swift
//  UniTice
//
//  Created by Presto on 29/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 광운대학교: UniversityModel {
    
    var name: String {
        return "광운대학교"
    }
    
    var categories: [광운대학교.Category] {
        return [
            ("", "전체"),
            ("5", "일반"),
            ("6", "학사"),
            ("16", "학생"),
            ("17", "봉사"),
            ("18", "등록/장학"),
            ("19", "입학"),
            ("20", "시설"),
            ("21", "병무"),
            ("22", "외부")
        ]
    }
    
    func pageURL(inCategory category: 광운대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\((page - 1) * 10)\(url4)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 광운대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 광운대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            print(url.absoluteString)
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let numbers = doc.xpath("//div[@class='board-list-box']//li//span[@class='ico-notice'] | //div[@class='board-list-box']//li//span[@class='no']")
            let titles = doc.xpath("//div[@class='board-list-box']//div[@class='board-text']//a//text()")
            let dates = doc.xpath("//div[@class='board-list-box']//div[@class='board-text']//p[@class='info']")
            let links = doc.xpath("//div[@class='board-list-box']//div[@class='board-text']//a/@href")
            for (index, element) in links.enumerated() {
                let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
                let title = titles[index].text?.trimmed ?? "?"
                let date = dates[index].text?.trimmed.split(separator: "|")[1].description.trimmed ?? "?"
                let link = element.text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 광운대학교 {
    private var url1: String {
        return "https://www.kw.ac.kr/ko/life/notice.do"
    }
    
    private var url2: String {
        return "?mode=list&srSearchKey=article_title&srCategoryId1="
    }
    
    private var url3: String {
        return "&article.offset="
    }
    
    private var url4: String {
        return "&srSearchVal="
    }
}

//https://www.kw.ac.kr/ko/life/notice.do?mode=list&srSearchVal=2018&srSearchKey=article_title&article.offset=0

////*[@id="jwxe_main_content"]/div/div/div[1]/div/ul/li[1]/span
////*[@id="jwxe_main_content"]/div/div/div[1]/div/ul/li[4]/span
////*[@id="jwxe_main_content"]/div/div/div[1]/div/ul/li[1]/div/a/text()

////*[@id="jwxe_main_content"]/div/div/div[1]/div/ul/li[4]/span

////*[@id="jwxe_main_content"]/div/div/div[1]/div/ul/li[1]/div/a/text()
