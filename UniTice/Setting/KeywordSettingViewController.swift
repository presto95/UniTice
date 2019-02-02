//
//  KeywordSettingViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import SnapKit

final class KeywordSettingViewController: UIViewController {
  
  private var keywords: [String] = []
  
  private lazy var addButton: UIBarButtonItem! = {
    let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTap(_:)))
    return button
  }()
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
      tableView.allowsSelection = false
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "키워드 설정"
    navigationItem.setRightBarButton(addButton, animated: false)
    if let keywords = User.fetch()?.keywords {
      self.keywords = keywords.map { String($0) }
    }
  }
  
  @objc private func addButtonDidTap(_ sender: UIBarButtonItem) {
    if keywords.count >= 3 {
      UIAlertController
        .alert(title: "", message: "3개 이상은 안돼요!")
        .action(title: "확인")
        .present(to: self)
    } else {
      UIAlertController
        .alert(title: "", message: "키워드")
        .textField()
        .action(title: "확인") { _, textFields in
          if let text = textFields?.first?.text?.replacingOccurrences(of: " ", with: "") {
            User.insertKeyword(text) { isDuplicated in
              if !isDuplicated {
                self.keywords.insert(text, at: 0)
                self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
              } else {
                UIAlertController
                  .alert(title: "", message: "키워드 중복")
                  .action(title: "확인")
                  .present(to: self)
              }
            }
          }
        }
        .action(title: "취소", style: .cancel)
        .present(to: self)
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
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return "최대 3개의 키워드를 등록할 수 있습니다. 현재 : \(keywords.count)개"
  }
}

extension KeywordSettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let keyword = keywords[indexPath.row]
      User.removeKeyword(keyword)
      keywords.remove(at: indexPath.row)
      tableView.reloadSections(IndexSet(0...0), with: .automatic)
    }
  }
}
