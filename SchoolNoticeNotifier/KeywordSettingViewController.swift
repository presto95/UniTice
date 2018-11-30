//
//  KeywordSettingViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit
import DZNEmptyDataSet

class KeywordSettingViewController: UIViewController {

    var keywords: [String] = ["dummy1", "dummy2", "dummy3"]
    lazy var tableView: UITableView! = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        return tableView
    }()
    lazy var addButton: UIBarButtonItem! = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchUpAddButton(_:)))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "키워드 설정"
        navigationItem.setRightBarButton(addButton, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    @objc func touchUpAddButton(_ sender: UIBarButtonItem) {
        if keywords.count >= 3 {
            UIAlertController
                .alert(title: "", message: "no more 3 keywords")
                .action(title: "확인")
                .present(to: self)
        } else {
            let alert = UIAlertController(title: "", message: "keyword", preferredStyle: .alert)
            alert.addTextField { _ in }
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                if let text = alert.textFields?.first?.text {
                    self.keywords.insert(text, at: 0)
                    self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension KeywordSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = keywords[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
}

extension KeywordSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "삭제") { _, _, _ in
            self.keywords.remove(at: indexPath.row)
            if self.keywords.count == 0 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }
}

extension KeywordSettingViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Add Keywords")
    }
}
