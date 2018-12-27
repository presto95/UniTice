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
    case kangwon = "강원대학교"
    case knu = "경북대학교"
    case gsnu = "경상대학교"
    case korea = "고려대학교"
    // ㄴ
    // ㄷ
    case dongduk = "동덕여자대학교"
    // ㄹ
    // ㅁ
    case mju = "명지대학교"
    // ㅂ
    case pusan = "부산대학교"
    // ㅅ
    case seoultech = "서울과학기술대학교"
    case snu = "서울대학교"
    // ㅇ
    // ㅈ
    case jnu = "전남대학교"
    case jbnu = "전북대학교"
    case jejunu = "제주대학교"
    // ㅊ
    case cnu = "충남대학교"
    case chungbuk = "충북대학교"
    // ㅋ
    // ㅌ
    // ㅍ
    // ㅎ
}

extension University {
    static func generateModel() -> UniversityModel {
        let user = User.fetch() ?? User()
        let university = University(rawValue: user.university) ?? .seoultech
        switch university {
        case .kangwon:
            return 강원대학교()
        case .knu:
            return 경북대학교()
        case .gsnu:
            return 경상대학교()
        case .korea:
            return 고려대학교()
        case .dongduk:
            return 동덕여자대학교()
        case .mju:
            return 명지대학교()
        case .pusan:
            return 부산대학교()
        case .snu:
            return 서울대학교()
        case .seoultech:
            return 서울과학기술대학교()
        case .jnu:
            return 전남대학교()
        case .jbnu:
            return 전북대학교()
        case .jejunu:
            return 제주대학교()
        case .cnu:
            return 충남대학교()
        case .chungbuk:
            return 충북대학교()
        }
    }
}
