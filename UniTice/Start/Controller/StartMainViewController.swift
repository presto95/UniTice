 //
//  StartMainViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class StartMainViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.image = UIImage()
        }
    }
    
    @IBOutlet private weak var confirmButton: StartConfirmButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        let next = UIViewController.instantiate(from: "Start", identifier: StartUniversitySelectViewController.classNameToString)
        navigationController?.pushViewController(next, animated: true)
    }
}
