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
import RxOptional
import RxSwift
import XLPagerTabStrip

/// The main container view controller.
final class MainContainerViewController: ButtonBarPagerTabStripViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = MainContainerViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var contentViewControllers: [MainContentTableViewController] = []
  
  @IBOutlet private weak var settingButtonItem: UIBarButtonItem!
  
  @IBOutlet private weak var searchButtonItem: UIBarButtonItem!
  
  @IBOutlet private weak var bookmarkButtonItem: UIBarButtonItem!
  
  // MARK: Method
  
  override func viewDidLoad() {
    setupButtonBar()
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    reloadPagerTabStripView()
    guard let reactor = reactor else { return }
    Observable.just(Void())
      .map { Reactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentRatingAlertInRandom()
  }
  
  override func viewControllers(
    for pagerTabStripController: PagerTabStripViewController
    ) -> [UIViewController] {
    return contentViewControllers
  }
  
  func bind(reactor: Reactor) {
    bindUI()
    bindAction(reactor)
    bindState(reactor)
  }
}

// MARK: - Reactor Binding

private extension MainContainerViewController {
  
  func bindAction(_ reactor: Reactor) {
    Observable.just(Void())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
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
    reactor.state.map { $0.isSettingButtonTapped }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let controller = StoryboardScene.Main.settingTableViewController.instantiate()
        controller.reactor = SettingTableViewReactor()
        controller.push(at: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isSearchButtonTapped }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let controller = StoryboardScene.Main.searchViewController.instantiate()
        guard let currentContentViewController
          = self.viewControllers[self.currentIndex] as? MainContentTableViewController,
          let currentContentViewReactor = currentContentViewController.reactor
          else { return }
        let currentCategory = currentContentViewReactor.currentState.category
        let university = currentContentViewReactor.currentState.university
        controller.reactor = SearchViewReactor(university: university, category: currentCategory)
        controller.push(at: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBookmarkButtonTapped }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let controller = StoryboardScene.Main.bookmarkViewController.instantiate()
        controller.reactor = BookmarkViewReactor()
        controller.push(at: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isUserNotificationRegistered }
      .distinctUntilChanged()
      .filterNil()
      .filter { !$0 }
      .subscribe(onNext: { [weak self] _ in
        let alert = UIAlertController
          .alert(title: "", message: "알림을 받을 수 없습니다.\n설정에서 알림 권한을 설정할 수 있습니다.")
          .action(title: "확인")
        self?.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    let university = Global.shared.universityModel
    university
      .map { $0.name }
      .subscribe(onNext: { [weak self] name in
        let barButtonItem = self?.makeUniversityBarButtonItem(self?.makeUniversityLabel(name))
        self?.navigationItem.setLeftBarButton(barButtonItem, animated: false)
      })
      .disposed(by: disposeBag)
    university
      .subscribe(onNext: { [weak self] university in
        guard let self = self else { return }
        self.contentViewControllers.removeAll()
        university.categories.forEach { category in
          let contentViewController = MainContentTableViewController().then {
            $0.reactor = MainContentTableViewReactor(university: university,
                                                     category: category)
          }
          self.contentViewControllers.append(contentViewController)
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension MainContainerViewController {
  
  func setupButtonBar() {
    settings.style.selectedBarHeight = 5
    settings.style.selectedBarBackgroundColor = .main
    settings.style.buttonBarBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    settings.style.buttonBarItemBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    settings.style.buttonBarItemTitleColor = .black
    settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
  }
  
  func makeUniversityLabel(_ name: String?) -> UILabel? {
    return UILabel().then {
      $0.text = name
      $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
      $0.sizeToFit()
    }
  }
  
  func makeUniversityBarButtonItem(_ label: UILabel?) -> UIBarButtonItem? {
    return UIBarButtonItem().then {
      $0.customView = label
    }
  }
  
  func presentRatingAlertInRandom() {
    if Int.random(in: 1...10) == 5 {
      SKStoreReviewController.requestReview()
    }
  }
}
