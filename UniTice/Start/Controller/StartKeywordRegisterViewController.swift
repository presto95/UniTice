//
//  StartKeywordRegisterViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit

class StartKeywordRegisterViewController: UIViewController {

    private var keywords: [String] = []
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpSuperView(_:))))
    }
    
    @objc private func touchUpSuperView(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        StartInfo.shared.keywords = keywords
        let next = UIViewController.instantiate(from: "Start", identifier: StartFinishViewController.classNameToString)
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc private func touchUpBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension StartKeywordRegisterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? KeywordCell else { return UITableViewCell() }
        cell.keywordLabel.text = keywords[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
}

extension StartKeywordRegisterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.instantiate(fromXib: "HeaderView") as? HeaderView
        headerView?.touchUpAddButtonHandler = { text in
            if self.keywords.count < 3 {
                self.keywords.insert(text, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } else {
                UIAlertController
                    .alert(title: "", message: "최대 3개까지 등록 가능합니다.")
                    .action(title: "확인")
                    .present(to: self)
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            keywords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
