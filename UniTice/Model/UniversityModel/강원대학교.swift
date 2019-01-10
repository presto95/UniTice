//
//  강원대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 강원대학교: UniversityScrappable {
    
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

    func requestPosts(inCategory category: 강원대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
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
                completion(posts, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension 강원대학교 {
    var baseURL: String {
        return "http://www.kangwon.ac.kr/www"
    }
    
    var commonQueries: String {
        return "/selectBbsNttList.do?pageUnit=10&searchCnd=SJ&key=277"
    }
    
    func categoryQuery(_ category: 강원대학교.Category) -> String {
        return "&bbsNo=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&pageIndex=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchKrwd=\(text.percentEncoding)"
    }
}
