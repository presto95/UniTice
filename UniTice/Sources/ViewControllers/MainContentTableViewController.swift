//
//  MainContentTableViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import XLPagerTabStrip

/// The main content table view controller.
final class MainContentTableViewController: UITableViewController,
                                            StoryboardView,
                                            SafariPresentable {
  
  // MARK: Typealias
  
  typealias Reactor = MainContentTableViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<UTSection>
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var dataSource: DataSource!
  
  private let headerView: MainNoticeHeaderView!
    = (UIView.instantiate(fromXib: MainNoticeHeaderView.name) as? MainNoticeHeaderView)?.then {
      $0.reactor = MainNoticeHeaderViewReactor()
  }
  
  private let footerRefreshView
    = FooterLoadingView(frame: CGRect(x: 0,
                                      y: 0,
                                      width: UIScreen.main.bounds.width,
                                      height: 32)).then {
                                        $0.reactor = FooterLoadingViewReactor()
  }
  
  private let cellIdentifier = "postCell"
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    tableView.delegate = nil
    tableView.dataSource = nil
    setup()
    super.viewDidLoad()
  }
  
  func bind(reactor: Reactor) {
    bindDataSource(reactor)
    bindUI()
    bindAction(reactor)
    bindState(reactor)
  }
  
  private func setup() {
    title = reactor?.currentState.category.description
    registerForPreviewing(with: self, sourceView: tableView)
    tableView.do {
      $0.tableFooterView = footerRefreshView
      $0.backgroundColor = .groupTableViewBackground
      $0.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
      $0.separatorColor = .main
      $0.register(PostCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    refreshControl = UIRefreshControl()
  }
}

// MARK: - Reactor Binding

private extension MainContentTableViewController {
  
  func bindAction(_ reactor: Reactor) {
    Observable.just(Void())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.swipeGesture(.up)
      .withLatestFrom(tableView.rx.contentOffset)
      .filter { [weak self] offset in
        guard let self = self else { return false }
        let offsetY = offset.y
        let contentHeight = self.tableView.contentSize.height
        return offsetY > contentHeight - self.tableView.bounds.height
      }
      .map { _ in Reactor.Action.scroll }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    refreshControl?.rx.controlEvent(.valueChanged)
      .map { Reactor.Action.refresh }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    headerView.rx.isUpperPostFolded
      .distinctUntilChanged()
      .map { Reactor.Action.toggleFolding($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.itemSelected
      .map { [weak self, weak reactor] indexPath -> Post? in
        guard let self = self, let reactor = reactor else { return nil }
        return self.makeBookmark(at: indexPath, state: reactor.currentState)
      }
      .filterNil()
      .map { Reactor.Action.interactWithCell($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    let upperPosts = reactor.state.map { $0.upperPosts }
    let standardPosts = reactor.state.map { $0.standardPosts }
    Observable.combineLatest(upperPosts, standardPosts) { first, second -> [UTSection] in
      let upperSectionData
        = first.map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
      let standardSectionData
        = second.map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
      let isFolded = reactor.currentState.isUpperPostFolded ?? false
      let upperPostSectionItems: [UTSectionData] = isFolded ? [] : upperSectionData
      return [.init(items: upperPostSectionItems), .init(items: standardSectionData)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isUpperPostFolded }
      .distinctUntilChanged()
      .filterNil()
      .map { Reactor.Action.toggleFolding($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .map { FooterLoadingViewReactor.Action.loading($0) }
      .bind(to: footerRefreshView.reactor!.action)
      .disposed(by: disposeBag)
    reactor.state.map { $0.isRefreshing }
      .distinctUntilChanged()
      .bind(to: refreshControl!.rx.isRefreshing)
      .disposed(by: disposeBag)
    reactor.state.map { $0.keywords }
      .subscribe(onNext: { [weak self] keywords in
        guard let self = self else { return }
        self.dataSource = .init(configureCell: { _, tableView, indexPath, sectionData in
          let cell
            = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
          if case let postCell as PostCell = cell {
            postCell.reactor = PostCellReactor(sectionData: sectionData, keywords: keywords)
          }
          return cell
        })
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension MainContentTableViewController {
  
  func bindDataSource(_ reactor: Reactor) {
    dataSource = .init(configureCell: { _, tableView, indexPath, sectionData in
      let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
      if case let postCell as PostCell = cell {
        postCell.reactor
          = PostCellReactor(sectionData: sectionData,
                            keywords: self.reactor?.currentState.keywords ?? [])
      }
      return cell
    })
    tableView.rx.itemSelected
      .map { [weak self, weak reactor] indexPath -> Post? in
        guard let self = self, let reactor = reactor else { return nil }
        return self.makeBookmark(at: indexPath, state: reactor.currentState)
      }
      .filterNil()
      .map { $0.link }
      .map { URL(string: $0) }
      .filterNil()
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.makeSafariViewController(url: $0).present(to: self)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
  }
  
  func makeBookmark(at indexPath: IndexPath, state: Reactor.State) -> Post? {
    let post = indexPath.section == 0
      ? state.upperPosts[indexPath.item]
      : state.standardPosts[indexPath.item]
    let university = state.university
    let category = state.category
    if let fullLink = university.postURL(inCategory: category, uri: post.link) {
      let fullLinkString = fullLink.absoluteString
      let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
      return bookmark
    }
    return nil
  }
}

// MARK: - Configuring UITableView

extension MainContentTableViewController {
  
  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    return section == 0 ? headerView : nil
  }
  
  override func tableView(_ tableView: UITableView,
                          viewForFooterInSection section: Int) -> UIView? {
    if section == 0 {
      return UIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 5)).then {
        $0.backgroundColor = .main
      }
    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 48 : .leastNonzeroMagnitude
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForFooterInSection section: Int) -> CGFloat {
    return section == 0 ? 5 : .leastNonzeroMagnitude
  }
}

// MARK: - Conforming UIViewControllerPreviewingDelegate

extension MainContentTableViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let reactor = reactor else { return nil }
    if let indexPath = tableView.indexPathForRow(at: location) {
      let currentState = reactor.currentState
      let post = indexPath.section == 0
        ? currentState.upperPosts[indexPath.item]
        : currentState.standardPosts[indexPath.item]
      let university = currentState.university
      let category = currentState.category
      if let fullLink = university.postURL(inCategory: category, uri: post.link) {
        let fullLinkString = fullLink.absoluteString
        let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
        Observable.just(Void())
          .map { Reactor.Action.interactWithCell(bookmark) }
          .bind(to: reactor.action)
          .disposed(by: disposeBag)
        return makeSafariViewController(url: fullLink)
      }
    }
    return nil
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true, completion: nil)
  }
}

// MARK: - Conforming IndicatorInfoProvider

extension MainContentTableViewController: IndicatorInfoProvider {
  
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: reactor?.currentState.category.description)
  }
}
