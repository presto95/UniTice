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

import Carte
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

/// The setting table view controller.
final class SettingTableViewController: UITableViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = SettingTableViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<SettingTableViewSection>
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var dataSource: DataSource!
  
  private let upperPostFoldingSwitch = UISwitch()
  
  override func viewDidLoad() {
    tableView.delegate = nil
    tableView.dataSource = nil
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
    title = "설정"
  }
}

// MARK: - Reactor Binding

private extension SettingTableViewController {
  
  func bindAction(_ reactor: Reactor) {
    Observable.just(Void())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    NotificationCenter.default.rx.notification(.willEnterForeground)
      .map { $0.userInfo?["hasNotificationGranted"] as? Bool ?? false }
      .map { Reactor.Action.fetchNotificationStatus($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    upperPostFoldingSwitch.rx.controlEvent(.valueChanged)
      .map { Reactor.Action.toggleUpperPostFoldingSwitch }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.sections }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isUpperPostFolded }
      .distinctUntilChanged()
      .bind(to: upperPostFoldingSwitch.rx.isOn)
      .disposed(by: disposeBag)
  }
}

private extension SettingTableViewController {
  
  func bindDataSource() {
    dataSource = .init(configureCell: { [weak self] _, tableView, indexPath, title in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      cell.textLabel?.text = title
      if indexPath.section == 0 {
        cell.accessoryView = self?.upperPostFoldingSwitch
      }
      return cell
    })
    dataSource.titleForFooterInSection = { dataSource, index in dataSource[index].footer }
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch indexPath.section {
        case 1 where row == 0:
          let controller = StoryboardScene.Setting.universityChangeViewController.instantiate()
          controller.reactor = UniversityChangeViewReactor()
          controller.push(at: self)
        case 1 where row == 1:
          let controller = StoryboardScene.Setting.keywordSettingViewController.instantiate()
          controller.reactor = KeywordSettingViewReactor()
          controller.push(at: self)
        case 1 where row == 2:
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        case 2 where row == 0:
          if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController().then {
              $0.mailComposeDelegate = self
              $0.setToRecipients(["yoohan95@gmail.com"])
            }
            self.present(mail, animated: true)
          }
        case 2 where row == 1:
          guard let url = URL(string: "itms-apps://itunes.apple.com/app/1447871519")
            else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case 3 where row == 0:
          CarteViewController().push(at: self)
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
