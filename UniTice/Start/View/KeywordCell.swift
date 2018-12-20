//
//  KeywordCell.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

@IBDesignable
class KeywordCell: UITableViewCell {

    @IBOutlet weak var keywordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        keywordLabel.layer.cornerRadius = keywordLabel.bounds.height / 2
        keywordLabel.layer.borderColor = UIColor.black.cgColor
        keywordLabel.layer.borderWidth = 1
    }
}
