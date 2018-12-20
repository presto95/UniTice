//
//  BottomButton.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

@IBDesignable
class StartConfirmButton: UIButton {
    
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
        layer.borderColor = UIColor.blue.cgColor
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
        setTitle("확인", for: [])
        setTitleColor(.blue, for: [])
    }
}
