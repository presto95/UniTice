//
//  Seoultech.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

struct Seoultech {
    var category: [String : String] {
        return [
            "notice": "대학공지사항",
            "matters": "학사공지",
            "janghak": "장학공지"
        ]
    }
    
    var url1: String = "http://www.seoultech.ac.kr/service/info/"
    
    var url2: String = "?bidx=6112&bnum=6112&allboard=true&page="
    
    var url3: String = "&size=5&searchtype=1&searchtext="
    
    func url(of category: String, inPage index: Int) -> String {
        return "\(url1)\(category)\(url2)\(index)\(url3)"
    }
}
