//
//  SettingTableViewController.swift
//  UniTice
//
//  Created by Presto on 30/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import MessageUI
import UIKit
import UserNotifications

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

/// 설정 테이블 뷰.
final class SettingTableViewController: UITableViewController, StoryboardView {
  
  typealias Reactor = SettingTableViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  var dataSource: RxTableViewSectionedReloadDataSource<SettingTableViewSection>!
  
  /// 상단 고정 게시물 스위치.
  private let upperPostFoldingSwitch = UISwitch()
  
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
    title = "설정"
  }
}

// MARK: - Reactor Binding

private extension SettingTableViewController {
  
  func bindAction(_ reactor: Reactor) {
    Observable<Bool>
      .create { observer in
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          observer.onNext(settings.authorizationStatus == .authorized)
          observer.onCompleted()
        }
        return Disposables.create()
      }
      .map { Reactor.Action.fetchNotificationStatus($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    NotificationCenter.default.rx.notification(.willEnterForeground)
      .map { $0.userInfo?["notificationHasGranted"] as? Bool ?? false }
      .map { Reactor.Action.fetchNotificationStatus($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    upperPostFoldingSwitch.rx.controlEvent(.valueChanged)
      .map { Reactor.Action.toggleUpperPostFoldSwitch }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.sections }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isUpperPostFolded }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isUpperPostFolded in
        self?.upperPostFoldingSwitch.setOn(isUpperPostFolded, animated: true)
        self?.tableView.reloadData()
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isNotificationGranted }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
        self?.tableView.reloadData()
      })
      .disposed(by: disposeBag)
  }
  
  func bindDataSource() {
    dataSource
      = RxTableViewSectionedReloadDataSource<SettingTableViewSection>
        .init(configureCell: { [weak self] dataSource, tableView, indexPath, title in
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
          cell.textLabel?.text = title
          if indexPath.section == 0 {
            cell.accessoryView = self?.upperPostFoldingSwitch
          }
          return cell
        })
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch indexPath.section {
        case 1 where row == 0:
          StoryboardScene.Setting.changeUniversityViewController.instantiate().push(at: self)
        case 1 where row == 1:
          StoryboardScene.Setting.keywordSettingViewController.instantiate().push(at: self)
        case 1 where row == 2:
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        case 2 where row == 0:
          if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["yoohan95@gmail.com"])
            self.present(mail, animated: true)
          }
        case 2 where row == 1:
          guard let url = URL(string: "itms-apps://itunes.apple.com/app/1447871519") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - MFMailComposeViewControllerDelegate 구현

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {
    controller.dismiss(animated: true)
  }
}
