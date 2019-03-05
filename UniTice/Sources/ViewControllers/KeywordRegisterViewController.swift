//
//  StartKeywordRegisterViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxGesture
import RxSwift
import SnapKit

final class KeywordRegisterViewController: UIViewController, StoryboardView {
  
  var disposeBag = DisposeBag()
  
  @IBOutlet private weak var tableView: UITableView!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  @IBOutlet private weak var backButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: KeywordRegisterViewReactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
  
  private func setup() {
    confirmButton.type = .next
    backButton.type = .back
    tableView.rowHeight = 60
    tableView.sectionHeaderHeight = 60
  }
}

// MARK: - Reactor Binding

private extension KeywordRegisterViewController {
  
  func bindAction(_ reactor: KeywordRegisterViewReactor) {
    tableView.rx.itemDeleted
      .map { Reactor.Action.removeKeyword(index: $0.row) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    confirmButton.rx.tap
      .map { Reactor.Action.touchUpConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    backButton.rx.tap
      .map { Reactor.Action.touchUpBackButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: KeywordRegisterViewReactor) {
    reactor.state.map { $0.keywords }
      .distinctUntilChanged()
      .bind(to: tableView.rx
        .items(cellIdentifier: "cell", cellType: KeywordCell.self)) { _, element, cell in
          if let keyword = element {
            cell.setKeyword(keyword)
          }
      }
      .disposed(by: disposeBag)
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        InitialInfo.shared.keywords.onNext(reactor.currentState.keywords.compactMap { $0 })
        let finishViewController = StoryboardScene.Start.startFinishViewController.instantiate()
        finishViewController.reactor = FinishViewReactor()
        finishViewController.push(at: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBackButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    view.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    tableView.rx.setDelegate(self)
  }
}

//extension StartKeywordRegisterViewController: UITableViewDataSource {
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//    if let keywordCell = cell as? KeywordCell {
//      keywordCell.setKeyword(keywords[indexPath.row])
//    }
//    return cell
//  }
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return keywords.count
//  }
//}
//
//extension StartKeywordRegisterViewController: UITableViewDelegate {
//  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    let headerView = UIView.instantiate(fromXib: "StartKeywordHeaderView") as? StartKeywordHeaderView
//    headerView?.addButtonDidTapHandler = { text in
//      if self.keywords.count < 3 {
//        self.keywords.insert(text, at: 0)
//        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//      } else {
//        UIAlertController
//          .alert(title: "", message: "최대 3개까지 등록 가능합니다.")
//          .action(title: "확인")
//          .present(to: self)
//      }
//    }
//    return headerView
//  }
//
//  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    return true
//  }
//
//  func tableView(_ tableView: UITableView,
//                 commit editingStyle: UITableViewCell.EditingStyle,
//                 forRowAt indexPath: IndexPath) {
//    if editingStyle == .delete {
//      keywords.remove(at: indexPath.row)
//      tableView.deleteRows(at: [indexPath], with: .automatic)
//    }
//  }
//}
//
//private extension StartKeywordRegisterViewController {
//  func bindUI() {
//    bindViewGesture()
//    bindConfirmButton()
//    bindBackButton()
//  }
//
//  func bindViewGesture() {
//    view.rx.tapGesture()
//      .when(.recognized)
//      .subscribe(onNext: { [weak self] _ in
//        guard let `self` = self else { return }
//        self.view.endEditing(true)
//      })
//      .disposed(by: disposeBag)
//  }
//
//  func bindConfirmButton() {
//    confirmButton.rx.tap
//      .subscribe(onNext: { [weak self] _ in
//        guard let `self` = self else { return }
//        InitialInfo.shared.keywords = self.keywords
//        let next
//          = UIViewController.instantiate(from: "Start", identifier: StartFinishViewController.classNameToString)
//        self.navigationController?.pushViewController(next, animated: true)
//      })
//      .disposed(by: disposeBag)
//  }
//
//  func bindBackButton() {
//    backButton.rx.tap
//      .subscribe(onNext: { [weak self] _ in
//        guard let `self` = self else { return }
//        self.navigationController?.popViewController(animated: true)
//      })
//      .disposed(by: disposeBag)
//  }
//}
