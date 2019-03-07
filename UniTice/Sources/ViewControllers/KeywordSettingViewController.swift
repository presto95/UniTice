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
  
  var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Void, String>>!
  
  let registerButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  
  @IBOutlet private weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
    bindDataSource()
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
    dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, String>>
      .init(configureCell: { dataSource, tableView, indexPath, keyword in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = keyword
        return cell
      })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    
  }
}

// MARK: - Private Method

private extension KeywordSettingViewController {
  
  func presentKeywordSettingAlertController() -> Observable<String?> {
    return Observable<String?>.create { observer in
      let alert = UIAlertController
        .alert(title: "", message: "등록할 키워드를 입력하세요.")
        .textField()
        .action(title: "확인", style: .default) { _, textFields in
          if let text = textFields?.first?.text {
            observer.onNext(text)
          }
          observer.onCompleted()
        }
        .action(title: "취소", style: .cancel) { _, _ in
          observer.onCompleted()
        }
      return Disposables.create {
        alert.dismiss(animated: true, completion: nil)
      }
    }
  }
}

//  @objc private func addButtonDidTap(_ sender: UIBarButtonItem) {
//    if keywords.count >= 3 {
//      UIAlertController
//        .alert(title: "", message: "3개 이상은 안돼요!")
//        .action(title: "확인")
//        .present(to: self)
//    } else {
//      UIAlertController
//        .alert(title: "", message: "키워드")
//        .textField()
//        .action(title: "확인") { _, textFields in
//          if let text = textFields?.first?.text?.replacingOccurrences(of: " ", with: "") {
//            User.insertKeyword(text) { isDuplicated in
//              if !isDuplicated {
//                self.keywords.insert(text, at: 0)
//                self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
//              } else {
//                UIAlertController
//                  .alert(title: "", message: "키워드 중복")
//                  .action(title: "확인")
//                  .present(to: self)
//              }
//            }
//          }
//        }
//        .action(title: "취소", style: .cancel)
//        .present(to: self)
//    }
//  }


//extension KeywordSettingViewController: UITableViewDataSource {
//  
//  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//    return "최대 3개의 키워드를 등록할 수 있습니다. 현재 : \(keywords.count)개"
//  }
//}
//
//extension KeywordSettingViewController: UITableViewDelegate {
//  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    return true
//  }
//  
//  func tableView(_ tableView: UITableView,
//                 commit editingStyle: UITableViewCell.EditingStyle,
//                 forRowAt indexPath: IndexPath) {
//    if editingStyle == .delete {
//      let keyword = keywords[indexPath.row]
//      User.removeKeyword(keyword)
//      keywords.remove(at: indexPath.row)
//      tableView.reloadSections(IndexSet(0...0), with: .automatic)
//    }
//  }
//}
