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
    
    private var keywords: [Keyword] = []
    
    private lazy var addButton: UIBarButtonItem! = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchUpAddButton(_:)))
        return button
    }()
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.emptyDataSetSource = self
            tableView.allowsSelection = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "키워드 설정"
        navigationItem.setRightBarButton(addButton, animated: false)
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        if let user = try? context?.fetch(User.fetchRequest()).last as? User {
            user?.keyword?.allObjects.forEach { element in
                if let keyword = element as? Keyword {
                    keywords.append(keyword)
                }
            }
        }
    }
    
    @objc private func touchUpAddButton(_ sender: UIBarButtonItem) {
        if keywords.count >= 3 {
            UIAlertController
                .alert(title: "", message: "3개 이상은 안돼요!")
                .action(title: "확인")
                .present(to: self)
        } else {
            let alert = UIAlertController(title: "", message: "키워드", preferredStyle: .alert)
            alert.addTextField { _ in }
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                if let text = alert.textFields?.first?.text {
                    if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                        if let user = try? context.fetch(User.fetchRequest()).last as? User {
                            let keyword = Keyword(context: context)
                            keyword.keyword = text
                            user?.addToKeyword(keyword)
                            self.keywords.insert(keyword, at: 0)
                        }
                        do {
                            try context.save()
                        } catch {
                            context.rollback()
                        }
                    }
                    if self.keywords.count == 1 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
                    }
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
        cell.textLabel?.text = keywords[indexPath.row].keyword
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
}

extension KeywordSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                if let user = try? context.fetch(User.fetchRequest()).last as? User {
                    user?.keyword?.allObjects.forEach { element in
                        if let keyword = element as? Keyword {
                            if keyword.keyword == keywords[indexPath.row].keyword {
                                user?.removeFromKeyword(keyword)
                                keywords.remove(at: indexPath.row)
                                return
                            }
                        }
                    }
                }
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
            }
            if keywords.count == 0 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension KeywordSettingViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "키워드를 추가하세요.")
    }
}
