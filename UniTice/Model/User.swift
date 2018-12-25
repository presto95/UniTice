//
//  User.swift
//  UniTice
//
//  Created by Presto on 25/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import RealmSwift

@objcMembers
class User {
    
    dynamic var university: String = ""
    
    dynamic var keywords: [String] = []
    
    dynamic var bookmarks: [Bookmark] = []
}

@objcMembers
class Bookmark {
    
    dynamic var index: Int = 0
    
    dynamic var title: String = ""
    
    dynamic var date: String = ""
    
    dynamic var link: String = ""
}
