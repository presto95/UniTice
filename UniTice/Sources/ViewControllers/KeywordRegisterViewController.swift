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

/// The keyword register view controller.
final class KeywordRegisterViewController: UIViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = KeywordRegisterViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<KeywordRegisterSection>
  
  // MARK: Property
  
  var disposeBag = DisposeBag()
  
  private var dataSource: DataSource!
  
  private let headerView
    = (UIView.instantiate(fromXib: KeywordRegisterHeaderView.name) as? KeywordRegisterHeaderView)?
      .then {
        $0.reactor = KeywordRegisterHeaderViewReactor()
  }
  
  @IBOutlet private weak var tableView: UITableView!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  @IBOutlet private weak var backButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: Reactor) {
    bindDataSource()
    bindUI()
    bindAction(reactor)
    bindState(reactor)
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
  
  func bindAction(_ reactor: Reactor) {
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    backButton.rx.tap
      .map { Reactor.Action.back }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.itemDeleted
      .map { Reactor.Action.removeKeyword(index: $0.item) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    headerView?.rx.textFieldDidEndEditing
      .filter { !$0.isEmpty }
      .map { Reactor.Action.returnKeyboard($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    reactor.state.map { $0.keywords }
      .map { [KeywordRegisterSection(items: $0)] }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        InitialInfo.shared.keywords.onNext(reactor.currentState.keywords)
        let controller = StoryboardScene.Start.startFinishViewController.instantiate()
        controller.reactor = FinishViewReactor()
        controller.push(at: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBackButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension KeywordRegisterViewController {
  
  func bindDataSource() {
    dataSource = .init(configureCell: { dataSource, tableView, indexPath, keyword in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      if case let keywordCell as KeywordCell = cell {
        keywordCell.reactor = KeywordCellReactor(keyword: keyword)
      }
      return cell
    })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    view.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        self?.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
  }
}

// MARK: - Conforming UITableViewDelegate

extension KeywordRegisterViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerView
  }
}
