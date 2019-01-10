//
//  성균관대학교.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 성균관대학교: UniversityScrappable {
    
    var name: String {
        return "성균관대학교"
    }
    
    var categories: [성균관대학교.Category] {
        return [
            ("01", "전체"),
            ("02", "학사"),
            ("03", "입학"),
            ("04", "취업"),
            ("05", "채용/모집"),
            ("06", "장학"),
            ("07", "행사/세미나"),
            ("07", "일반")
        ]
    }
    
    func postURL(inCategory category: 성균관대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueries)\(categoryQuery(category))\(link.percentEncoding)") else {
            throw UniversityError.invalidURLError
        }
        return url
    }
    
    func requestPosts(inCategory category: 성균관대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let numbers = doc.xpath("//table[@class='board_list']//tbody//td[1]")
                let titles = doc.xpath("//table[@class='board_list']//tbody//td[@class='left']//a")
                let dates = doc.xpath("//table[@class='board_list']//tbody//td[3]")
                let links = doc.xpath("//table[@class='board_list']//tbody//td[@class='left']//a/@href")
                for (index, element) in links.enumerated() {
                    let number = Int(numbers[index].text?.trimmed ?? "") ?? 0
                    let title = titles[index].text?.trimmed ?? "?"
                    let date = dates[index].text?.trimmed ?? "?"
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

extension 성균관대학교 {
    var baseURL: String {
        return "https://www.skku.edu/skku/campus/skk_comm/"
    }
    
    var commonQueries: String {
        return "notice"
    }
    
    func categoryQuery(_ category: 성균관대학교.Category) -> String {
        return "\(category.identifier).do"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "?mode=list&srSearchKey=article_title&article.offset=\((page - 1) * 10)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&srSearchVal=\(text.percentEncoding)"
    }
}
