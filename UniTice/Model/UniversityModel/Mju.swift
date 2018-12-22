//
//  Mju.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Kanna

struct Mju: UniversityModel {
    
    var name: String {
        return "명지대학교"
    }
    
    var categories: [Mju.Category]
    
    func pageURL(inCategory category: Mju.Category, inPage page: Int, searchText: String) -> String {
        return ""
    }
    
    func postURL(inCategory category: Mju.Category, link: String) -> String {
        return ""
    }
    
    func requestPosts(inCategory category: Mju.Category, inPage page: Int, completion: @escaping (([Post]) -> Void)) {
        
    }
}
