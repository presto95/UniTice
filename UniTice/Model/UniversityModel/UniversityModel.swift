//
//  UniversityModel.swift
//  UniTice
//
//  Created by Presto on 10/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

class UniversityModel {

    init() { universityModel = 서울과학기술대학교() }
    
    static let shared = UniversityModel()
    
    var universityModel: UniversityScrappable
    
    func generateModel() {
        let user = User.fetch() ?? User()
        let university = University(rawValue: user.university) ?? .seoultech
        switch university {
        case .kaist:
            universityModel = KAIST()
        case .kcu:
            universityModel = KC대학교()
        case .kangnam:
            universityModel = 강남대학교()
        case .kangwon:
            universityModel = 강원대학교()
        case .knu:
            universityModel = 경북대학교()
        case .gsnu:
            universityModel = 경상대학교()
        case .ks:
            universityModel = 경성대학교()
        case .khu:
            universityModel = 경희대학교()
        case .korea:
            universityModel = 고려대학교()
        case .kw:
            universityModel = 광운대학교()
        case .kookmin:
            universityModel = 국민대학교()
        case .daejin:
            universityModel = 대진대학교()
        case .duksung:
            universityModel = 덕성여자대학교()
        case .dongguk:
            universityModel = 동국대학교()
        case .dongduk:
            universityModel = 동덕여자대학교()
        case .dsu:
            universityModel = 동신대학교()
        case .mju:
            universityModel = 명지대학교()
        case .mokpo:
            universityModel = 목포대학교()
        case .pknu:
            universityModel = 부경대학교()
        case .pusan:
            universityModel = 부산대학교()
        case .syu:
            universityModel = 삼육대학교()
        case .skuniv:
            universityModel = 서경대학교()
        case .seoultech:
            universityModel = 서울과학기술대학교()
        case .snue:
            universityModel = 서울교육대학교()
        case .snu:
            universityModel = 서울대학교()
        case .swu:
            universityModel = 서울여자대학교()
        case .skhu:
            universityModel = 성공회대학교()
        case .sungkyul:
            universityModel = 성결대학교()
        case .skku:
            universityModel = 성균관대학교()
        case .sungshin:
            universityModel = 성신여자대학교()
        case .sejong:
            universityModel = 세종대학교()
        case .sehan:
            universityModel = 세한대학교()
        case .sookmyung:
            universityModel = 숙명여자대학교()
        case .woosuk:
            universityModel = 우석대학교()
        case .ewha:
            universityModel = 이화여자대학교()
        case .jnu:
            universityModel = 전남대학교()
        case .jbnu:
            universityModel = 전북대학교()
        case .jejunu:
            universityModel = 제주대학교()
        case .chongshin:
            universityModel = 총신대학교()
        case .cnu:
            universityModel = 충남대학교()
        case .chungbuk:
            universityModel = 충북대학교()
        case .kpu:
            universityModel = 한국산업기술대학교()
        case .karts:
            universityModel = 한국예술종합학교()
        case .hufs:
            universityModel = 한국외국어대학교()
        case .hansung:
            universityModel = 한성대학교()
        case .hanyang:
            universityModel = 한양대학교()
        case .hongik:
            universityModel = 홍익대학교()
        }
    }
}
