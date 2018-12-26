//
//  School.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 11/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

enum University: String, CaseIterable {
    
    // ㄱ
    // ㄴ
    // ㄷ
    case dongduk = "동덕여자대학교"
    // ㄹ
    // ㅁ
    case mju = "명지대학교"
    // ㅂ
    // ㅅ
    case seoultech = "서울과학기술대학교"
    case snu = "서울대학교"
    // ㅇ
    // ㅈ
    case jnu = "전남대학교"
    case jejunu = "제주대학교"
    // ㅊ
    // ㅋ
    // ㅌ
    // ㅍ
    // ㅎ
}

extension University {
    static func generateModel() -> UniversityModel {
        let user = User.fetch() ?? User()
        let university = University(rawValue: user.university) ?? .dongduk
        switch university {
        case .dongduk:
            return 동덕여자대학교()
        case .mju:
            return 명지대학교()
        case .snu:
            return 서울대학교()
        case .seoultech:
            return 서울과학기술대학교()
        case .jnu:
            return 전남대학교()
        case .jejunu:
            return 제주대학교()
        }
    }
}
