//
//  StartFinishViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import CoreData

class StartFinishViewController: UIViewController {
    
    @IBOutlet weak var universityLabel: UILabel! {
        didSet {
            universityLabel.text = StartInfo.shared.university.rawValue
        }
    }
    
    @IBOutlet weak var keywordLabel: UILabel! {
        didSet {
            let keywords = StartInfo.shared.keywords
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
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var backButton: StartBackButton! {
        didSet {
            backButton.addTarget(self, action: #selector(touchUpBackButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        // Core Data에 초기 설정 저장
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
                user.university = StartInfo.shared.university.rawValue
                StartInfo.shared.keywords.forEach { text in
                    let keyword = Keyword(context: context)
                    keyword.keyword = text
                    user.addToKeyword(keyword)
                }
            }
            do {
                try context.save()
            } catch {
                context.rollback()
            }
            
        }
        let next = UIViewController.instantiate(from: "Main", identifier: "MainNavigationController")
        next.modalTransitionStyle = .flipHorizontal
        present(next, animated: true, completion: nil)
    }
    
    @objc private func touchUpBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
