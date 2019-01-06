//
//  부경대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 부경대학교: UniversityModel {
    
    var name: String {
        return "부경대학교"
    }
    
    var categories: [부경대학교.Category] {
        return [
            ("", "전체"),
            ("2", "일반공지"),
            ("6", "행사안내"),
            ("5", "학사안내"),
            ("3", "등록·장학"),
            ("1", "기타공지")
        ]
    }
    
    func requestPosts(inCategory category: 부경대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//tr//td[@class='title']//a/@href")
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
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension 부경대학교 {
    var baseURL: String {
        return "http://www.pknu.ac.kr"
    }
    
    var commonQueries: String {
        return "/usrBoardActn.do?p_bm_idx=5&p_boardcode=PK10000005"
    }
    
    func categoryQuery(_ category: 부경대학교.Category) -> String {
        return "&p_sbsidx=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&p_pageno=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&p_skey=title&p_stext=\(text.percentEncoding)"
    }
}

//http://www.pknu.ac.kr/usrBoardActn.do?p_bm_idx=5&p_boardcode=PK10000005&p_pageno=3&p_skey=title&p_stext=2018&p_sbsidx=2


