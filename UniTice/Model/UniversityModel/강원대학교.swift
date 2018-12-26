//
//  강원대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 강원대학교: UniversityModel {
    
    var name: String {
        return "강원대학교"
    }
    
    var categories: [강원대학교.Category] {
        return [
            ("81", "공지사항"),
            ("38", "행사안내"),
            ("39", "인사/채용"),
            ("117", "취업정보")
        ]
    }
    
    func pageURL(inCategory category: 강원대학교.Category, inPage page: Int, searchText: String = "") -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(page)\(url4)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 강원대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 강원대학교.Category, inPage page: Int, _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page)) else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            let rows = doc.xpath("//table[@class='bbs_default list']//tbody[@class='tb']//td")
            let links = doc.xpath("//table[@class='bbs_default list']//tbody[@class='tb']//td[@class='subject']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 7
                let titleIndex = index * 7 + 2
                let dateIndex = index * 7 + 5
                let campusIndex = index * 7 + 1
                let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmed ?? "?"
                let date = rows[dateIndex].text?.trimmed ?? "?"
                var link = element.text?.trimmed ?? "?"
                link.removeFirst()
                let campus = rows[campusIndex].text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: "\(date) | \(campus)", link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 강원대학교 {
    private var url1: String {
        return "http://www.kangwon.ac.kr/www"
    }
    
    private var url2: String {
        return "/selectBbsNttList.do?pageUnit=10&searchCnd=SJ&key=277&bbsNo="
    }
    
    private var url3: String {
        return "&pageIndex="
    }
    
    private var url4: String {
        return "&searchKrwd="
    }
}

//http://www.kangwon.ac.kr/www/selectBbsNttList.do?bbsNo=81&&pageUnit=10&searchCnd=SJ&searchKrwd=2018&key=277&pageIndex=2

//http://www.kangwon.ac.kr/www/selectBbsNttList.do?bbsNo=38&&pageUnit=10&searchCnd=SJ&searchKrwd=2018&key=279&pageIndex=2
