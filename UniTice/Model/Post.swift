//
//  Post.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 11/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

struct Post: CustomStringConvertible {
    
    let number: Int
    
    let category: String
    
    let title: String
    
    let date: String
    
    let link: String
    
    var description: String {
        return """
        -----
        글번호 : \(number)
        카테고리 : \(category)
        제목 : \(title)
        날짜 : \(date)
        링크 : \(link)
        -----
        """
    }
}
