//
//  String+.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func highlightKeywords(_ keywords: [String]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        if !keywords.isEmpty {
            for keyword in keywords {
                do {
                    let regex = try NSRegularExpression(pattern: keyword, options: .caseInsensitive)
                    let range = NSRange(location: 0, length: utf16.count)
                    for match in regex.matches(in: self, options: .withTransparentBounds, range: range) {
                        attributedString.addAttributes([
                            .backgroundColor: UIColor.main.withAlphaComponent(0.7),
                            .foregroundColor: UIColor.white
                            ], range: match.range)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return attributedString
    }
    
    var percentEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String.Encoding {
    static let eucKR = String.Encoding.init(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
}
