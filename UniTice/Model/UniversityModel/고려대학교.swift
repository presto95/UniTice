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
    
    func pageURL(inCategory category: 고려대학교.Category, inPage page: Int, searchText text: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueries)\(categoryQuery(category))\(pageQuery(page))\(searchQuery(text))") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func postURL(inCategory category: 고려대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(categoryQueryForPost(category))\(linkQueryForPost(link))") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 고려대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
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
                completion(posts, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension 고려대학교 {
    var baseURL: String {
        return "http://www.korea.ac.kr/cop/portalBoard/"
    }
    
    var commonQueries: String {
        return "portalBoardList.do?siteId=university"
    }
    
    func categoryQuery(_ category: 고려대학교.Category) -> String {
        return "&type=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&findType=SUBJECT&findWord=\(text.percentEncoding)"
    }
}

private extension 고려대학교 {
    var commonQueriesForPost: String {
        return "portalBoardView.do?siteId=university"
    }
    
    func categoryQueryForPost(_ category: 고려대학교.Category) -> String {
        return "&type=\(category.identifier)"
    }
    
    func linkQueryForPost(_ articleId: String) -> String {
        return "&articleId=\(articleId)"
    }
}
