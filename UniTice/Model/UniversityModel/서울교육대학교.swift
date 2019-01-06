//
//  서울교육대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 서울교육대학교: UniversityModel {
    
    var name: String {
        return "서율교육대학교"
    }
    
    var categories: [서울교육대학교.Category] {
        return [
            ("notice", "공지사항"),
            ("graduate_notice", "학사공지"),
            ("janghak", "장학"),
            ("cheyong", "채용")
        ]
    }
    
    func postURL(inCategory category: 서울교육대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(categoryQuery(category))\(postNumber(link))") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 서울교육대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let numbers = doc.xpath("//td[@class='td1']")
                let titles = doc.xpath("//td[@class='td2']")
                let dates = doc.xpath("//td[@class='td4']")
                let links = doc.xpath("//tr/@onclick")
                for (index, element) in links.enumerated() {
                    let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
                    let title = titles[index].text?.trimmed ?? "?"
                    let date = dates[index].text?.trimmed ?? "?"
                    let link = element.text?.trimmed.filter { Int("\($0)") != nil } ?? "?"
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

extension 서울교육대학교 {
    var baseURL: String {
        return "http://portal.snue.ac.kr/enview/board"
    }
    
    var commonQueries: String {
        return "/list.brd?srchType=Subj"
    }
    
    func categoryQuery(_ category: 서울교육대학교.Category) -> String {
        return "&boardId=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&srchKey=\(text.percentEncoding)"
    }
    
    private var commonQueriesForPost: String {
        return "/read.brd?cmd=READ"
    }
    
    private func postNumber(_ number: String) -> String {
        return "&bltnNo=\(number)"
    }
}
