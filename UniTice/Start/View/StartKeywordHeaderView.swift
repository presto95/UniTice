//
//  HeaderView.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class StartKeywordHeaderView: UIView {
    
    var touchUpAddButtonHandler: ((String) -> Void)?
    
    @IBOutlet private weak var keywordTextField: UITextField! {
        didSet {
            keywordTextField.delegate = self
        }
    }
    
    @IBOutlet private weak var addButton: UIButton! {
        didSet {
            addButton.imageView?.contentMode = .scaleAspectFit
            addButton.addTarget(self, action: #selector(touchUpAddButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpAddButton(_ sender: UIButton) {
        if let text = keywordTextField.text {
            touchUpAddButtonHandler?(text)
            keywordTextField.text = nil
        }
    }
}

extension StartKeywordHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
