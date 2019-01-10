//
//  한양대학교.swift
//  UniTice
//
//  Created by Presto on 10/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

struct 한양대학교: UniversityScrappable {
    
    var name: String {
        return "한양대학교"
    }
    
    var categories: [한양대학교.Category] {
        return [
            ("1", "학사"),
            ("2", "입학"),
            ("3", "모집/채용"),
            ("4", "사회봉사"),
            ("5", "일반"),
            ("6", "산학/연구"),
            ("7", "행사"),
            ("8", "장학"),
            ("9", "학회/세미나")
        ]
    }
    
    func postURL(inCategory category: 한양대학교.Category, uri link: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(commonQueries)\(messageIdForPost(link))") else {
            throw UniversityError.invalidURLError
        }
        print(url.absoluteString)
        return url
    }
    
    func requestPosts(inCategory category: 한양대학교.Category, inPage page: Int, searchText text: String, _ completion: @escaping (([Post]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var posts = [Post]()
            do {
                let url = try self.pageURL(inCategory: category, inPage: page, searchText: text)
                let doc = try HTML(url: url, encoding: .utf8)
                let titles = doc.xpath("//tbody//tr//p[@class='title']")
                let dates = doc.xpath("//tbody//tr//td//div[@class='notice-date']")
                let links = doc.xpath("//tbody//tr//td//p[@class='title']//a/@href")
                for (index, element) in links.enumerated() {
                    let mappedTitles = titles[index].text?.trimmed.components(separatedBy: "\r\n").map { $0.trimmed }.filter { !$0.isEmpty }
                    let number = mappedTitles?.first == "주요알림" ? 0 : 1
                    let campus: String
                    switch mappedTitles?.count {
                    case 3:
                        campus = mappedTitles?[1] ?? "?"
                    case 2:
                        campus = mappedTitles?.first ?? "?"
                    default:
                        campus = ""
                    }
                    let title = mappedTitles?.last ?? "?"
                    let date = dates[index].text?.trimmed ?? "?"
                    let link = element.text?.trimmed.filter { Int("\($0)") != nil } ?? "?"
                    let post = Post(number: number, title: title, date: "\(campus) | \(date)", link: link)
                    posts.append(post)
                }
                completion(posts, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension 한양대학교 {
    var baseURL: String {
        return "https://www.hanyang.ac.kr/web/www/notice_all"
    }
    
    var commonQueries: String {
        return "?p_p_id=viewNotice_WAR_noticeportlet&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_count=1"
    }
    
    func categoryQuery(_ category: 한양대학교.Category) -> String {
        return "&_viewNotice_WAR_noticeportlet_sCategoryId=\(category.identifier)"
    }
    
    func pageQuery(_ page: Int) -> String {
        return "&_viewNotice_WAR_noticeportlet_sCurPage=\(page)"
    }
    
    func searchQuery(_ text: String) -> String {
        return "&_viewNotice_WAR_noticeportlet_action=view&_viewNotice_WAR_noticeportlet_sKeyType=title&_viewNotice_WAR_noticeportlet_sKeyword=\(text.percentEncoding)"
    }
    
    private func messageIdForPost(_ text: String) -> String {
        return "&_viewNotice_WAR_noticeportlet_action=view_message&_viewNotice_WAR_noticeportlet_messageId=\(text)"
    }
}
