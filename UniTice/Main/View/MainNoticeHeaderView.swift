//
//  MainNoticeHeaderView.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class MainNoticeHeaderView: UIView {
    
    var state: Bool = false {
        didSet {
            foldButton.setTitle(state ? "펼치기" : "접기", for: [])
        }
    }
    
    var foldingHandler: (() -> Void)?
    
    @IBOutlet weak var foldButton: UIButton! {
        didSet {
            foldButton.addTarget(self, action: #selector(touchUpFoldButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpFoldButton(_ sender: UIButton) {
        foldingHandler?()
    }
}
