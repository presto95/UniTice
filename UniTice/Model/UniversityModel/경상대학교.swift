//
//  경상대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 경상대학교: UniversityModel {
    
    var name: String {
        return "경상대학교"
    }
    
    var categories: [경상대학교.Category] {
        return [
            ("10026", "HOT NEWS"),
            ("10027", "학사공지"),
            ("10303", "기관공지"),
            ("10028", "학술/행사"),
            ("10030", "입찰정보"),
            ("10029", "보도자료"),
            ("11531", "HOT ISSUE"),
            ("10579", "교육소식")
        ]
    }
    
    func pageURL(inCategory category: 경상대학교.Category, inPage page: Int, searchText: String) -> String {
        return "\(url1)\(url2)\(category.name)\(url3)\(page)\(url4)\(searchText.percentEncoding)"
    }
    
    func postURL(inCategory category: 경상대학교.Category, link: String) -> String {
        return "\(url1)\(link)"
    }
    
    func requestPosts(inCategory category: 경상대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            guard let url = URL(string: self.pageURL(inCategory: category, inPage: page, searchText: text)) else { return }
            guard let doc = try? HTML(url: url, encoding: .init(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))) else { return }
            let rows = doc.xpath("//tbody[@class='tb']//td")
            let links = doc.xpath("//tbody[@class='tb']//td[@class='subject']//a[1]/@href")
            let realRows = Array(rows.dropFirst(rows.count % links.count))
            let divisor: Int
            let dateIndexIncrement: Int
            switch category.name {
            case "10026":
                divisor = 7
                dateIndexIncrement = 4
            case "10027", "10029", "11531", "10579":
                divisor = 5
                dateIndexIncrement = 3
            default:
                divisor = 6
                dateIndexIncrement = 4
            }
            for (index, element) in links.enumerated() {
                let numberIndex = index * divisor
                let titleIndex = index * divisor + 1
                let dateIndex = index * divisor + dateIndexIncrement
                let number = Int(realRows[numberIndex].text?.trimmed ?? "") ?? 0
                let title = realRows[titleIndex].text?.trimmed ?? "?"
                let date = realRows[dateIndex].text?.trimmed ?? "?"
                let link = element.text?.trimmed ?? "?"
                let post = Post(number: number, title: title, date: date, link: link)
                posts.append(post)
            }
            completion(posts)
        }
    }
}

extension 경상대학교 {
    private var url1: String {
        return "https://www.gnu.ac.kr/program/multipleboard/"
    }
    
    private var url2: String {
        return "BoardList.jsp?groupNo="
    }
    
    private var url3: String {
        return "&cpage="
    }
    
    private var url4: String {
        return "&searchType=&category=&type=&searchString="
    }
}
