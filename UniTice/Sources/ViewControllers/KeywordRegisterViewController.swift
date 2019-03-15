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
  
  var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Void, KeywordCellReactor>>!
  
  @IBOutlet private weak var tableView: UITableView!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  @IBOutlet private weak var backButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: KeywordRegisterViewReactor) {
    bindDataSource()
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
      .map { Reactor.Action.removeKeyword(index: $0.item) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    backButton.rx.tap
      .map { Reactor.Action.back }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: KeywordRegisterViewReactor) {
    reactor.state.map { $0.keywords }
      .map { keywords -> [SectionModel<Void, KeywordCellReactor>] in
        let items = keywords.map { KeywordCellReactor(keyword: $0) }
        let sectionModel = SectionModel(model: Void(), items: items)
        return [sectionModel]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        InitialInfo.shared.keywords.onNext(reactor.currentState.keywords.compactMap { $0 })
        let controller = StoryboardScene.Start.startFinishViewController.instantiate()
        controller.reactor = FinishViewReactor()
        controller.push(at: self)
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
  
  func bindDataSource() {
    dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, KeywordCellReactor>>
      .init(configureCell: { dataSource, tableView, indexPath, reactor in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let keywordCell = cell as? KeywordCell {
          keywordCell.reactor = reactor
        }
        return cell
      })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    view.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
  }
}

extension KeywordRegisterViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let headerView: KeywordRegisterHeaderView
      = UIView.instantiate(fromXib: KeywordRegisterHeaderView.classNameToString) {
      headerView.reactor = KeywordRegisterHeaderViewReactor()
      return headerView
    }
    return nil
  }
}
