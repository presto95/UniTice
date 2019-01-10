//
//  KC대학교.swift
//  UniTice
//
//  Created by Presto on 06/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct KC대학교: UniversityScrappable {
    
    var name: String {
        return "KC대학교"
    }
    
    var categories: [KC대학교.Category] {
        return [
            ("BC0701", "KC공지"),
            ("BC0702", "학사"),
            ("EC0101", "입학"),
            ("BC0703", "장학"),
            ("GC0101", "비교과행사"),
            ("BC0704", "입찰공고")
        ]
    }
    
    func postURL(inCategory category: KC대학교.Category, uri link: String) throws -> URL {
        switch category.identifier {
        case "EC0101":
            guard let url = URL(string: link.percentEncoding) else {
                throw UniversityError.invalidURLError
            }
            return url
        default:
            guard let url = URL(string: "\(baseURL)\(link.percentEncoding)") else {
                throw UniversityError.invalidURLError
            }
            return url
        }
    }
    
    func requestPosts(inCategory category: KC대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//tbody//tr//td")
                let links = doc.xpath("//tbody//td[@class='b_sub']//a/@href")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 6
                    let titleIndex = index * 6 + 1
                    let dateIndex = index * 6 + 3
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

extension KC대학교 {
    var baseURL: String {
        return "http://kcu.ac.kr"
    }
    
    var commonQueries: String {
        return ""
    }
    
    func categoryQuery(_ category: KC대학교.Category) -> String {
        var result = ""
        switch category.identifier {
        case "EC0101":
            result += "/kcui"
        case "GC0101":
            result += "/kcug"
        default:
            result += "/kcua"
        }
        return result + "/boardList?menuCode=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&thisPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&searchCode=2&searchKey=\(text.percentEncoding)"
    }
}
