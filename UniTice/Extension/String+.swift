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
                    let range = NSRange(location: 0, length: self.utf16.count)
                    for match in regex.matches(in: self, options: .withTransparentBounds, range: range) {
                        attributedString.addAttributes([
                            .backgroundColor: UIColor.cyan,
                            .foregroundColor: UIColor.purple,
                            .font: UIFont.systemFont(ofSize: 15, weight: .heavy)
                            ], range: match.range)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return attributedString
    }
}
