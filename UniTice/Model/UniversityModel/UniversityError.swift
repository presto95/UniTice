//
//  UniversityError.swift
//  UniTice
//
//  Created by Presto on 30/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation

enum UniversityError: Error {
    
    case invalidURLError
    
    case htmlParseError
}

extension UniversityError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .invalidURLError:
            return "잘못된 URL 형식입니다."
        case .htmlParseError:
            return "HTML 파싱을 실패하였습니다."
        }
    }
}
