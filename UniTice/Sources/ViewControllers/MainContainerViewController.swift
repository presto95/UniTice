//
//  MainBaseViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import StoreKit
import UIKit
import UserNotifications

import ReactorKit
import RxCocoa
import RxSwift
import XLPagerTabStrip

final class MainContainerViewController: ButtonBarPagerTabStripViewController, StoryboardView {
  
  typealias Reactor = MainContainerViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var universityModel: UniversityType = UniversityModel.shared.universityModel {
    didSet {
      (navigationItem.leftBarButtonItem?.customView as? UILabel)?.text = universityModel.name
    }
  }
  
  @IBOutlet private weak var settingButtonItem: UIBarButtonItem!
  
  @IBOutlet private weak var searchButtonItem: UIBarButtonItem!
  
  @IBOutlet private weak var bookmarkButtonItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    setupButtonBar()
    super.viewDidLoad()
    registerLocalNotification()
    setupUniversityLabel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    universityModel = UniversityModel.shared.universityModel
    reloadPagerTabStripView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if Int.random(in: 1...10) == 5 {
      SKStoreReviewController.requestReview()
    }
  }
  
  override func viewControllers(
    for pagerTabStripController: PagerTabStripViewController
  ) -> [UIViewController] {
    var viewControllers: [UITableViewController] = []
    universityModel.categories.indices.forEach { index in
      let contentViewController = MainContentTableViewController().then {
        $0.categoryIndex = index
        $0.universityModel = universityModel
      }
      viewControllers.append(contentViewController)
    }
    return viewControllers
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
//
//  @IBAction private func searchButtonDidTap(_ sender: UIBarButtonItem) {
//    let next = StoryboardScene.Main.searchViewController.instantiate()
//    next.category
//      = (viewControllers(for: self)[currentIndex] as? MainContentTableViewController)?.category
//    navigationController?.pushViewController(next, animated: true)
//  }
}

// MARK: - Reactor Binding

private extension MainContainerViewController {
  
  func bindAction(_ reactor: Reactor) {
    settingButtonItem.rx.tap
      .map { Reactor.Action.setting }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    searchButtonItem.rx.tap
      .map { Reactor.Action.search }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    bookmarkButtonItem.rx.tap
      .map { Reactor.Action.bookmark }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    
  }
  
  func bindUI() {
    
  }
}

// MARK: - Private Method

private extension MainContainerViewController {
  
  func makeUniversityLabel() -> UILabel {
    return UILabel().then {
      $0.text = universityModel.name
      $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
      $0.sizeToFit()
    }
  }
  
  func makeLeftBarButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem()
  }
  
  func setupUniversityLabel() {
    let universityLabel = UILabel()
    universityLabel.text = universityModel.name
    universityLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    universityLabel.sizeToFit()
    let leftBarButtonItem = UIBarButtonItem(customView: universityLabel)
    navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
  }
  
  func setupButtonBar() {
    settings.style.selectedBarHeight = 5
    settings.style.selectedBarBackgroundColor = .main
    settings.style.buttonBarBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    settings.style.buttonBarItemBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    settings.style.buttonBarItemTitleColor = .black
    settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
  }
  
  func registerLocalNotification() {
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current()
      .requestAuthorization(options: authOptions) { isGranted, error in
        if let error = error {
          errorLog(error.localizedDescription)
          // fatalError(error.localizedDescription)
        }
        if !UserDefaults.standard.bool(forKey: "showsAlertIfPermissionDenied") {
          let content = UNMutableNotificationContent()
          content.title = ""
          content.body = "오늘은 무슨 공지사항이 새로 올라왔을까요? 확인해 보세요."
          var dateComponents = DateComponents()
          dateComponents.hour = 9
          dateComponents.minute = 0
          let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
          let request = UNNotificationRequest(identifier: "localNotification",
                                              content: content,
                                              trigger: trigger)
          UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            print(error?.localizedDescription ?? "")
          })
          if !isGranted {
            UIAlertController
              .alert(title: "", message: "알림을 받을 수 없습니다.\n설정에서 알림 권한을 설정할 수 있습니다.")
              .action(title: "확인")
              .present(to: self)
          }
        }
        UserDefaults.standard.set(true, forKey: "showsAlertIfPermissionDenied")
    }
  }
}
