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

    private var keywords: [String] = ["학점", "장학", "철회"]
    
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
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
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
        let headerView = UIView.instantiate(fromXib: "HeaderView")
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
