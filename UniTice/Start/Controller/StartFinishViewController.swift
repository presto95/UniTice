//
//  StartFinishViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

final class StartFinishViewController: UIViewController {
  
  @IBOutlet weak var universityLabel: UILabel! {
    didSet {
      universityLabel.text = InitialInfo.shared.university.rawValue
    }
  }
  
  @IBOutlet weak var keywordLabel: UILabel! {
    didSet {
      let keywords = InitialInfo.shared.keywords
      if keywords.isEmpty {
        keywordLabel.text = "없음"
      } else {
        var result = ""
        for (index, keyword) in keywords.enumerated() {
          if index + 1 == keywords.count {
            result += keyword
          } else {
            result += keyword + ", "
          }
        }
        keywordLabel.text = result
      }
    }
  }
  
  @IBOutlet private weak var confirmButton: StartConfirmButton! {
    didSet {
      confirmButton.addTarget(self, action: #selector(confirmButtonDidTap(_:)), for: .touchUpInside)
    }
  }
  
  @IBOutlet private weak var backButton: StartBackButton! {
    didSet {
      backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
    }
  }
  
  @objc private func confirmButtonDidTap(_ sender: UIButton) {
    let university = InitialInfo.shared.university.rawValue
    let keywords = InitialInfo.shared.keywords
    let user = User()
    user.university = university
    user.keywords.append(objectsIn: keywords)
    User.addUser(user)
    UniversityModel.shared.generateModel()
    let next = UIViewController.instantiate(from: "Main", identifier: "MainNavigationController")
    next.modalTransitionStyle = .flipHorizontal
    present(next, animated: true, completion: nil)
  }
  
  @objc private func backButtonDidTap(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
}
