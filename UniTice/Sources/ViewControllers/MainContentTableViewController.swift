//
//  MainContentTableViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import XLPagerTabStrip

/// The main content table view controller.
final class MainContentTableViewController: UITableViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = MainContentTableViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<UTSection>
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var dataSource: RxTableViewSectionedReloadDataSource<UTSection>!
  
  private let headerView
    = (UIView.instantiate(fromXib: MainNoticeHeaderView.name) as? MainNoticeHeaderView)?.then {
      $0.reactor = MainNoticeHeaderViewReactor()
  }
  
  private let footerRefreshView
    = FooterRefreshView(frame: CGRect(x: 0,
                                      y: 0,
                                      width: UIScreen.main.bounds.width,
                                      height: 32)).then {
                                        $0.reactor = FooterRefreshViewReactor()
  }
  
  private let cellIdentifier = "postCell"
  
  // MARK: Life Cycle
  
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
    title = reactor?.currentState.category.description
    registerForPreviewing(with: self, sourceView: tableView)
    tableView.tableFooterView = footerRefreshView
    tableView.backgroundColor = .groupTableViewBackground
    tableView.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
    tableView.separatorColor = .main
    tableView.register(PostCell.self, forCellReuseIdentifier: cellIdentifier)
    refreshControl = UIRefreshControl()
  }
}

// MARK: - Reactor Binding

private extension MainContentTableViewController {
  
  func bindAction(_ reactor: Reactor) {
    refreshControl?.rx.controlEvent(.valueChanged)
      .map { Reactor.Action.refresh }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.contentOffset
      .filter { [weak self] offset in
        guard let self = self else { return false }
        let offsetY = offset.y
        let contentHeight = self.tableView.contentSize.height
        return offsetY > contentHeight - self.tableView.bounds.height
      }
      .filter { _ in !reactor.currentState.isLoading }
      .map { _ in Reactor.Action.scroll }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    headerView?.reactor?.state.map { $0.isUpperPostFolded }
      .distinctUntilChanged()
      .map { Reactor.Action.toggleFolding($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.posts }
      .map { posts -> [UTSection] in
        let fixedPosts = posts
          .filter { $0.number == 0 }
          .map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
        let standardPosts = posts
          .filter { $0.number != 0 }
          .map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
        return [.init(items: fixedPosts), .init(items: standardPosts)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .map { FooterRefreshViewReactor.Action.loading($0) }
      .bind(to: footerRefreshView.reactor!.action)
      .disposed(by: disposeBag)
  }
}

private extension MainContentTableViewController {
  
  func bindDataSource() {
    dataSource = .init(configureCell: { dataSource, tableView, indexPath, sectionData in
      let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
      if case let postCell as PostCell = cell {
        postCell.reactor = PostCellReactor(post: sectionData)
      }
      return cell
    })
    
  }
  
  func bindUI() {
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    
  }
}

extension MainContentTableViewController {
  //  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
  //    let offsetY = scrollView.contentOffset.y
  //    let contentHeight = scrollView.contentSize.height
  //    if offsetY > contentHeight - scrollView.bounds.height {
  //      if !footerRefreshView.isLoading {
  //        footerRefreshView.activate()
  //        page += 1
  //      }
  //    }
  
}

extension MainContentTableViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    tableView.deselectRow(at: indexPath, animated: true)
    //    let post = indexPath.section == 0 ? fixedPosts[indexPath.row] : standardPosts[indexPath.row]
    //    let fullLink = universityModel.postURL(inCategory: category, uri: post.link)
    //    let fullLinkString = fullLink.absoluteString
    //    let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
    //    User.insertBookmark(bookmark)
    //    present(safariViewController(url: fullLink), animated: true)
  }
  
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

extension MainContentTableViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    if let indexPath = tableView.indexPathForRow(at: location) {
      let currentState = reactor?.currentState
      let post = indexPath.section == 0
        ? currentState?.fixedPosts[indexPath.item]
        : currentState?.standardPosts[indexPath.item]
      let university = currentState?.university
      let category = currentState?.category
      let fullLink = university?.postURL(inCategory: category, uri: post.link)
      let fullLinkString = fullLink.absoluteString
      let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
      User.insertBookmark(bookmark)
      return safariViewController(url: fullLink)
    }
    return nil
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true, completion: nil)
  }
}

extension MainContentTableViewController: IndicatorInfoProvider {
  
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: reactor?.currentState.category.description)
  }
}

extension MainContentTableViewController: SafariViewControllerPresentable { }
