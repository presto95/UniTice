//
//  StartBackButton.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

@IBDesignable
class StartBackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.red.cgColor
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        setTitle("뒤로", for: [])
        setTitleColor(.red, for: [])
    }
}
