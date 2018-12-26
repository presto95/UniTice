//
//  충남대학교.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct 충남대학교: UniversityModel {
    
    var name: String {
        return "충남대학교"
    }
    
    var categories: [충남대학교.Category]
    
    func pageURL(inCategory category: 충남대학교.Category, inPage page: Int, searchText: String = "") -> String {
        return ""
    }
    
    func postURL(inCategory category: 충남대학교.Category, link: String) -> String {
        return ""
    }
    
    func requestPosts(inCategory category: 충남대학교.Category, inPage page: Int, _ completion: @escaping (([Post]) -> Void)) {
        
    }
}
