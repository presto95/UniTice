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

/// The keyword setting view controller.
final class KeywordSettingViewController: UIViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = KeywordSettingViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<KeywordSection>
  
  // MARK: Property
  
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
        return [.init(footer: footer, items: keywords)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isAlertPresenting }
      .distinctUntilChanged()
      .filter { $0 }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.makeKeywordSettingAlertController()
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension KeywordSettingViewController {
  
  func bindDataSource() {
    dataSource = .init(configureCell: { _, tableView, indexPath, keyword in
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
  
  /// Creates the alert controller for registering a keyword.
  func makeKeywordSettingAlertController() -> Observable<Reactor.Action> {
    return Observable<Reactor.Action>.create { [weak self] observer in
      let alert = UIAlertController
        .alert(title: "", message: "등록할 키워드를 입력하세요.")
        .textField { $0.placeholder = "키워드" }
        .action(title: "확인") { _, textFields in
          let text = textFields?.first?.text
          observer.onNext(Reactor.Action.alertConfirm(text))
          observer.onCompleted()
        }
        .action(title: "취소", style: .cancel) { _, _ in
          observer.onNext(Reactor.Action.alertCancel)
          observer.onCompleted()
      }
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create {
        alert.dismiss(animated: true, completion: nil)
      }
    }
  }
}
