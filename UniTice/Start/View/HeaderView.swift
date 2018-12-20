//
//  HeaderView.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    @IBOutlet private weak var keywordAddButton: UIButton! {
        didSet {
            keywordAddButton.imageView?.contentMode = .scaleAspectFit
            keywordAddButton.layer.cornerRadius = keywordAddButton.bounds.height / 2
            keywordAddButton.layer.borderWidth = 1
            keywordAddButton.layer.borderColor = UIColor.black.cgColor
        }
    }
}
