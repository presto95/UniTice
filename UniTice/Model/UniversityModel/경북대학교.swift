//
//  경북대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 경북대학교: UniversityScrappable {
    
    var name: String {
        return "경북대학교"
    }
    
    var categories: [경북대학교.Category] {
        return [
            ("1", "공지사항"),
            ("11", "행사"),
            ("12", "교외행사"),
            ("8", "경북대채용")
        ]
    }

    func requestPosts(inCategory category: 경북대학교.Category, inPage page: Int, searchText text: String = "", _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let rows = doc.xpath("//div[@class='board_list']//tbody//td")
                let links = doc.xpath("//div[@class='board_list']//tbody//td[@class='subject']//a/@href")
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

extension 경북대학교 {
    var baseURL: String {
        return "https://www.knu.ac.kr"
    }
    
    var commonQueries: String {
        return "/wbbs/wbbs/bbs/btin/list.action?&input_search_type=search_subject&btin.search_type=search_subject"
    }
    
    func categoryQuery(_ category: 경북대학교.Category) -> String {
        return "&bbs_cde=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&btin.page=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&input_search_text=\(text.percentEncoding)&btin.search_text=\(text.percentEncoding)"
    }
}
