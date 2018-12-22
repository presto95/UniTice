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
    // ㅇ
    // ㅈ
    // ㅊ
    // ㅋ
    // ㅌ
    // ㅍ
    // ㅎ
    
    static func generateModel() -> UniversityModel {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        if let universityString = try? (context?.fetch(User.fetchRequest()).last as? User)?.university {
            let university = University(rawValue: universityString ?? "") ?? .dongduk
            switch university {
            case .dongduk:
                return Seoultech()
            case .mju:
                return Seoultech()
            case .seoultech:
                return Seoultech()
            }
        } else {
            return Seoultech()
        }
    }
}
