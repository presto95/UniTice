//
//  강남대학교.swift
//  UniTice
//
//  Created by Presto on 07/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 강남대학교: UniversityScrappable {
    
    var name: String {
        return "강남대학교"
    }
    
    var categories: [강남대학교.Category] {
        return [
            ("116", "학사"),
            ("117", "장학"),
            ("118", "학습/상담"),
            ("344", "취창업")
        ]
    }
    
    func postURL(inCategory category: 강남대학교.Category, uri link: String) throws -> URL {
        let links = link.components(separatedBy: "|")
        let first = links.first?.trimmed ?? "?"
        let second = links.last?.trimmed ?? "?"
        guard let url = URL(string: "\(baseURL)\(commonQueriesForPost)\(commonQueries)\(encMenuSeq(first))\(encMenuBoardSeq(second))") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 강남대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//div[@class='tbody']//ul//li")
                let links = doc.xpath("//div[@class='tbody']//ul//li//a/@data-params")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 7
                    let titleIndex = index * 7 + 2
                    let dateIndex = index * 7 + 5
                    let number = Int(rows[numberIndex].text?.trimmed ?? "") ?? 0
                    let title = rows[titleIndex].text?.trimmed ?? "?"
                    let date = rows[dateIndex].text?.trimmed ?? "?"
                    let link = element.text?.trimmed ?? "?"
                    let data = Data(link.utf8)
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    let encMenuSeq = json?["encMenuSeq"] as? String ?? "?"
                    let encMenuBoardSeq = json?["encMenuBoardSeq"] as? String ?? "?"
                    let combination = "\(encMenuSeq)|\(encMenuBoardSeq)"
                    let post = Post(number: number, title: title, date: date, link: combination)
                    posts.append(post)
                }
                completion(posts, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension 강남대학교 {
    var baseURL: String {
        return "http://web.kangnam.ac.kr/menu/"
    }
    
    var commonQueries: String {
        return "f19069e6134f8f8aa7f689a4a675e66f.do?"
    }
    
    func categoryQuery(_ category: 강남대학교.Category) -> String {
        return "&searchMenuSeq=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&paginationInfo.currentPageNo=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchType=ttl&searchValue=\(text.percentEncoding)"
    }
    
    private var commonQueriesForPost: String {
        return "board/info/"
    }
    
    private func encMenuSeq(_ text: String) -> String {
        return "&encMenuSeq=\(text)"
    }
    
    private func encMenuBoardSeq(_ text: String) -> String {
        return "&encMenuBoardSeq=\(text)"
    }
}
