//
//  Dongduk.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct Dongduk: UniversityModel {
    
    var name: String {
        return "동덕여자대학교"
    }
    
    var categories: [Dongduk.Category]
    
    func pageURL(inCategory category: Dongduk.Category, inPage page: Int, searchText: String) -> String {
        return ""
    }
    
    func postURL(inCategory category: Dongduk.Category, link: String) -> String {
        return ""
    }
    
    func requestPosts(inCategory category: Dongduk.Category, inPage page: Int, completion: @escaping (([Post]) -> Void)) {
        
    }
}
