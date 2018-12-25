//
//  StartInfo.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

class InitialInfo {
    
    static let shared = InitialInfo()
    
    var university: University = .dongduk
    
    var keywords: [String] = []
}
