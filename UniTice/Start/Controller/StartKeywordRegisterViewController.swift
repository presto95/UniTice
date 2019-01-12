//
//  StartKeywordRegisterViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class StartKeywordRegisterViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private var keywords: [String] = []
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet private weak var confirmButton: StartConfirmButton!
    
    @IBOutlet private weak var backButton: StartBackButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        
        let tableViewRx = tableView.rx
        tableViewRx
            .itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.keywords.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            .disposed(by: disposeBag)
    }
}

extension StartKeywordRegisterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? KeywordCell else { return UITableViewCell() }
        cell.setKeyword(keywords[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
}

extension StartKeywordRegisterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.instantiate(fromXib: "StartKeywordHeaderView") as? StartKeywordHeaderView
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

private extension StartKeywordRegisterViewController {
    func bindUI() {
        bindViewGesture()
        bindConfirmButton()
        bindBackButton()
    }
    
    func bindViewGesture() {
        view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    func bindConfirmButton() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                InitialInfo.shared.keywords = self.keywords
                let next = UIViewController.instantiate(from: "Start", identifier: StartFinishViewController.classNameToString)
                self.navigationController?.pushViewController(next, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bindBackButton() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
