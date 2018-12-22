//
//  UniversityModel.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

protocol UniversityModel {
    
    typealias Category = (name: String, description: String)
    
    var name: String { get }
    
    var categories: [Category] { get }
    
    func pageURL(inCategory category: Category, inPage page: Int, searchText: String) -> String
    
    func postURL(inCategory category: Category, link: String) -> String
    
    func requestPosts(inCategory category: Category, inPage page: Int, completion: @escaping (([Post]) -> Void))
}
