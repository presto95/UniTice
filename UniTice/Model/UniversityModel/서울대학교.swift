//
//  Snu.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 서울대학교: UniversityModel {
    
    var name: String {
        return "서울대학교"
    }
    
    var categories: [서울대학교.Category] {
        return [
            ("notice", "일반공지")
        ]
    }
    
    func pageURL(inCategory category: 서울대학교.Category, inPage page: Int, searchText text: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueries)\(categoryQuery(category))\(pageQuery(page))\(searchQuery(text))") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func postURL(inCategory category: 서울대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(link.percentEncoding)") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 서울대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//table[@class='table01n_list']//tbody//td")
                let links = doc.xpath("//table[@class='table01n_list']//tbody//a/@href")
                for (index, element) in links.enumerated() {
                    let numberIndex = index * 4
                    let titleIndex = index * 4 + 1
                    let dateIndex = index * 4 + 2
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

extension 서울대학교 {
    var baseURL: String {
        return "http://www.snu.ac.kr/"
    }
    
    var commonQueries: String {
        return ""
    }
    
    func categoryQuery(_ category: 서울대학교.Category) -> String {
        return category.identifier
    }
    
    func pageQuery(_ page: Int) -> String {
        return "?page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&bt=t&bq=\(text.percentEncoding)"
    }
}
