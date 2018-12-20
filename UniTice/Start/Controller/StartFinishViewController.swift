//
//  StartFinishViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class StartFinishViewController: UIViewController {
    
    @IBOutlet private weak var confirmButton: StartConfirmButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var backButton: StartBackButton! {
        didSet {
            backButton.addTarget(self, action: #selector(touchUpBackButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        let next = UIViewController.instantiate(from: "Main", identifier: "MainNavigationController")
        next.modalTransitionStyle = .flipHorizontal
        present(next, animated: true, completion: nil)
    }
    
    @objc private func touchUpBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
