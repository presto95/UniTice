//
//  충남대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct 충남대학교: UniversityScrappable {
    
    var name: String {
        return "충남대학교"
    }
    
    var categories: [충남대학교.Category] {
        return [
            ("0701", "새소식"),
            ("0702", "학사정보"),
            ("0704", "교육정보"),
            ("0709", "사업단 창업ㆍ교육"),
            ("0705", "채용/초빙")
        ]
    }
    
    func requestPosts(inCategory category: 충남대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
        Kanna.shared.request(pageURL(inCategory: category, inPage: page, searchText: text)) { doc, error in
            guard let doc = doc else {
                completion(nil, error)
                return
            }
            var posts = [Post]()
            let rows = doc.xpath("//div[@class='board_list']//tbody//td")
            let links = doc.xpath("//div[@class='board_list']//tbody//td[@class='title']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 6
                let titleIndex = index * 6 + 1
                let dateIndex = index * 6 + 3
                let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmed ?? "?"
                let date = rows[dateIndex].text?.trimmed ?? "?"
                var realLink = element.text?.trimmed ?? "?"
                realLink.removeFirst()
                let post = Post(number: number, title: title, date: date, link: realLink)
                posts.append(post)
            }
            completion(posts, nil)
        }
    }
}

extension 충남대학교 {
    var baseURL: String {
        return "http://plus.cnu.ac.kr/_prog/_board/"
    }
    
    var commonQueries: String {
        return "?site_dvs_cd=kr&site_dvs=&ntt_tag="
    }
    
    func categoryQuery(_ category: 충남대학교.Category) -> String {
        return "&menu_dvs_cd=\(category.identifier)&code=sub07_\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&GotoPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&skey=title&sval=\(text.percentEncoding)"
    }
}
