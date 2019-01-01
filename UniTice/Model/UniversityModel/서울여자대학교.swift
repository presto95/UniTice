//
//  서울여자대학교.swift
//  UniTice
//
//  Created by Presto on 01/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 서울여자대학교: UniversityModel {
    
    var name: String {
        return "서울여자대학교"
    }
    
    var categories: [서울여자대학교.Category] {
        return [
            ("4", "학사"),
            ("5", "장학"),
            ("6", "행사"),
            ("7", "채용/취업"),
            ("8", "일반/봉사")
        ]
    }
    
    func postURL(inCategory category: 경북대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueriesForPost(category))\(link)") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 서울여자대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//tr//td[@class='title']//a/@onclick")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 5
                    let titleIndex = index * 5 + 1
                    let dateIndex = index * 5 + 3
                    let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                    let title = rows[titleIndex].text?.trimmed ?? "?"
                    let date = rows[dateIndex].text?.trimmed ?? "?"
                    let tempLink = element.text?.trimmed.map { String($0) } ?? []
                    var link = ""
                    for character in tempLink {
                        if let digit = Int(character) {
                            link += "\(digit)"
                        }
                    }
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

extension 서울여자대학교 {
    var baseURL: String {
        return "http://www.swu.ac.kr/front"
    }
    
    var commonQueries: String {
        return "/boardlist.do?"
    }
    
    func categoryQuery(_ category: 서울여자대학교.Category) -> String {
        return "&bbsConfigFK=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&currentPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchField=D.TITLE&searchValue=\(text.percentEncoding)"
    }
    
    private func commonQueriesForPost(_ category: 서울여자대학교.Category) -> String {
        return "/boardview.do?bbsConfigFK=\(category.identifier)&pkid="
    }
}
