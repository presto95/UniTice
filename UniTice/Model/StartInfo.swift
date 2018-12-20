//
//  StartInfo.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

class StartInfo {
    
    static let shared = StartInfo()
    
    var university: University = .dongduk
    
    var keywords: [String] = []
}
