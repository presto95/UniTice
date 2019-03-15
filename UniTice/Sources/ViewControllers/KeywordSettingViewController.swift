//
//  KeywordSettingViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import RxViewController
import SnapKit

/// 설정 키워드 설정 뷰 컨트롤러.
final class KeywordSettingViewController: UIViewController, StoryboardView {
  
  typealias Reactor = KeywordSettingViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, String>>
    .init(configureCell: { dataSource, tableView, indexPath, keyword in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      cell.textLabel?.text = keyword
      return cell
    })
  
  private let registerButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  
  @IBOutlet private weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: Reactor) {
    bindDataSource()
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
  
  private func setup() {
    title = "키워드 설정"
    navigationItem.setRightBarButton(registerButtonItem, animated: false)
    tableView.allowsSelection = false
  }
}

// MARK: - Reactor Binding

private extension KeywordSettingViewController {
  
  func bindAction(_ reactor: Reactor) {
    rx.viewDidLoad
      .map { Reactor.Action.didPresent }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    registerButtonItem.rx.tap
      .map { Reactor.Action.register }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {  
    reactor.state.map { $0.keywords }
      .map { keywords -> [SectionModel<Void, String>] in
        return [SectionModel(model: Void(), items: keywords)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  func bindDataSource() {
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    
  }
}

// MARK: - Private Method

private extension KeywordSettingViewController {
  
  func presentKeywordSettingAlertController() {
    UIAlertController
      .alert(title: "", message: "등록할 키워드를 입력하세요.")
      .textField()
      .action(title: "확인", style: .default) { [weak self, weak reactor] _, textFields in
        guard let self = self else { return }
        guard let reactor = reactor else { return }
        let text = textFields?.first?.text
        Observable.just(text).map { Reactor.Action.alertConfirm($0) }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
      }
      .action(title: "취소", style: .cancel) { [weak self, weak reactor] _, _ in
        guard let self = self else { return }
        guard let reactor = reactor else { return }
        Observable.empty().map { Reactor.Action.alertCancel }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
      }
      .present(to: self)
  }
}
