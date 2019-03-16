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
import SnapKit

/// 설정 키워드 설정 뷰 컨트롤러.
final class KeywordSettingViewController: UIViewController, StoryboardView {
  
  typealias Reactor = KeywordSettingViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<KeywordSection>
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var dataSource: DataSource! 

  private let registerButtonItem
    = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  
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
  }
}

// MARK: - Reactor Binding

private extension KeywordSettingViewController {
  
  func bindAction(_ reactor: Reactor) {
    Observable.just(Void())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    registerButtonItem.rx.tap
      .filter { reactor.currentState.keywords.count < 3 }
      .map { Reactor.Action.register }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.itemDeleted
      .map { Reactor.Action.deleteKeyword(index: $0.item) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {  
    reactor.state.map { $0.keywords }
      .map { keywords -> [KeywordSection] in
        let footer = "최대 3개의 키워드를 등록할 수 있습니다. 현재 : \(keywords.count)개"
        return [KeywordSection(footer: footer, items: keywords)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isAlertPresenting }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.makeKeywordSettingAlertController().present(to: self)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension KeywordSettingViewController {
  
  func bindDataSource() {
    dataSource = .init(configureCell: { dataSource, tableView, indexPath, keyword in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      cell.textLabel?.text = keyword
      return cell
    })
    dataSource.titleForFooterInSection = { dataSource, index in dataSource[index].footer }
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func makeKeywordSettingAlertController() -> UIAlertController {
    return UIAlertController
      .alert(title: "", message: "등록할 키워드를 입력하세요.")
      .textField { $0.placeholder = "키워드" }
      .action(title: "확인", style: .default) { [weak self, weak reactor] _, textFields in
        guard let self = self, let reactor = reactor else { return }
        let text = textFields?.first?.text
        Observable.just(text).map { Reactor.Action.alertConfirm($0) }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
      }
      .action(title: "취소", style: .cancel) { [weak self, weak reactor] _, _ in
        guard let self = self, let reactor = reactor else { return }
        Observable.just(Void()).map { Reactor.Action.alertCancel }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
    }
  }
}
