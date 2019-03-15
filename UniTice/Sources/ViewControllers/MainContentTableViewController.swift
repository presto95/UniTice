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

final class MainContentTableViewController: UITableViewController, StoryboardView {
  
  typealias Reactor = MainContentTableViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private lazy var footerRefreshView
    = FooterRefreshView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 32))
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  private func setup() {
    title = reactor?.currentState.category.description
    registerForPreviewing(with: self, sourceView: tableView)
    tableView.tableFooterView = footerRefreshView
    tableView.backgroundColor = .groupTableViewBackground
    tableView.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
    tableView.separatorColor = .main
    tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
    refreshControl = UIRefreshControl()
  }
  
  private func makeSafariViewController(url: URL) -> SFSafariViewController {
    let config = SFSafariViewController.Configuration().then {
      $0.barCollapsingEnabled = true
      $0.entersReaderIfAvailable = true
    }
    let viewController = SFSafariViewController(url: url, configuration: config).then {
      $0.preferredControlTintColor = .main
      $0.dismissButtonStyle = .close
    }
    return viewController
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
}

// MARK: - Reactor Binding

private extension MainContentTableViewController {
  
  func bindAction(_ reactor: Reactor) {
    refreshControl?.rx.controlEvent(.valueChanged)
      .map { Reactor.Action.refresh }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.contentOffset.asObservable()
      .filter { [weak self] offset in
        guard let self = self else { return false }
        let offsetY = offset.y
        let contentHeight = self.tableView.contentSize.height
        return offsetY > contentHeight - self.tableView.bounds.height
      }
      .map { _ in Reactor.Action.scroll }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.posts }
      .bind(to: tableView.rx.items(cellIdentifier: "postCell", cellType: PostCell.self)) { row, post, cell in
        
      }
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    
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
//    if section == 0 {
//      guard let headerView = UIView
//        .instantiate(fromXib: MainNoticeHeaderView.classNameToString) as? MainNoticeHeaderView
//        else { return nil }
//      headerView.state = isFixedNoticeFolded
//      headerView.foldingHandler = {
//        self.isFixedNoticeFolded = !self.isFixedNoticeFolded
//        self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
//      }
//      return headerView
//    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView,
                          viewForFooterInSection section: Int) -> UIView? {
    if section == 0 {
      let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 5))
      footerView.backgroundColor = .main
      return footerView
    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 48
    }
    return .leastNonzeroMagnitude
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForFooterInSection section: Int) -> CGFloat {
    if section == 0 {
      return 5
    }
    return .leastNonzeroMagnitude
  }
}

extension MainContentTableViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
//    if let indexPath = tableView.indexPathForRow(at: location) {
//      let post = indexPath.section == 0 ? fixedPosts[indexPath.row] : standardPosts[indexPath.row]
//      let fullLink = universityModel.postURL(inCategory: category, uri: post.link)
//      let fullLinkString = fullLink.absoluteString
//      print(fullLinkString)
//      let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
//      User.insertBookmark(bookmark)
//      return safariViewController(url: fullLink)
//    }
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
