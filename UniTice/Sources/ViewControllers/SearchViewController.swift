//
//  SearchViewController.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

/// 검색 뷰 컨트롤러.
final class SearchViewController: UIViewController, StoryboardView {
  
  typealias Reactor = SearchViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  var dataSource: RxTableViewSectionedReloadDataSource<UTSection>!
  
  private lazy var footerRefreshView
    = FooterRefreshView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 32))
  
  private lazy var searchController = UISearchController(searchResultsController: nil).then {
    $0.searchBar.placeholder = "제목"
    $0.hidesNavigationBarDuringPresentation = false
  }
  
  var searchBar: UISearchBar {
    return searchController.searchBar
  }
  
  @IBOutlet private weak var tableView: UITableView!
  
  let headerView = UIView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchController.isActive = true
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
    bindDataSource()
    bindUI()
    
    searchBar.rx.searchButtonClicked
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.searchController.isActive = false
      })
      .disposed(by: disposeBag)
  }
  
  private func setup() {
    registerForPreviewing(with: self, sourceView: tableView)
    headerView.bounds.size.height = 48
    let headerLabel = UILabel().then {
      $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    headerView.addSubview(headerLabel)
    headerLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = footerRefreshView
    definesPresentationContext = true
    navigationItem.titleView = searchController.searchBar
  }
}

// MARK: - Reactor Binding

private extension SearchViewController {
  
  func bindAction(_ reactor: Reactor) {
    searchBar.rx.text
      .map { Reactor.Action.updateSearchText($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    searchController.rx.didPresent
      .map { Reactor.Action.didPresent }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    searchBar.rx.searchButtonClicked
      .map { Reactor.Action.search }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.contentOffset.asObservable()
      .skipUntil(reactor.state.map { $0.isSearching }.filter { $0 })
      .skipUntil(footerRefreshView.reactor?.state.map { $0.isRefreshing }.filter { !$0 } ?? .empty())
      .filter { [weak self] offset in
        guard let self = self else { return false }
        return offset.y > self.tableView.contentSize.height - self.tableView.bounds.height
      }
      .map { _ in Reactor.Action.scroll }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isPresented }
      .distinctUntilChanged()
      .filter { $0 }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.searchBar.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
//    reactor.state.map { $0.posts }
//      .map { posts -> [UTSectionData] in
//        return posts.map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
//      }
//      .map { UTSection(items: $0) }
//      .bind(to: tableView.rx.items(dataSource: dataSource))
//      .disposed(by: disposeBag)
    
  }
  
  func bindDataSource() {
    dataSource = RxTableViewSectionedReloadDataSource<UTSection>
      .init(configureCell: { dataSource, tableView, indexPath, data in
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        cell.textLabel?.text = data.title
        cell.detailTextLabel?.text = data.date
        return cell
      })
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
    tableView.rx.modelSelected(UTSectionData.self)
      .subscribe(onNext: { [weak self] sectionData in
        guard let self = self else { return }
        
        
      })
      .disposed(by: disposeBag)
  }
}

//extension SearchViewController: UITableViewDelegate {
//
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//    let post = posts[indexPath.row]
//    let fullLink = universityModel.postURL(inCategory: category, uri: post.link)
//    let fullLinkString = fullLink.absoluteString
//    let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
//    User.insertBookmark(bookmark)
//    present(safariViewController(url: fullLink), animated: true)
//  }
//}

// MARK: - UIViewControllerPreviewingDelegate 구현

extension SearchViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
//    if let indexPath = tableView.indexPathForRow(at: location) {
//      let post = reactor?.currentState.posts[indexPath.row]
//      let fullLink = universityModel.postURL(inCategory: category, uri: post.link)
//      let fullLinkString = fullLink.absoluteString
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

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//    DispatchQueue.main.async {
//      self.searchController.isActive = false
//    }
//    posts.removeAll()
//    searchButtonHasClicked = true
//    searchText = searchBar.text ?? ""
//    requestPosts(searchText: searchText)
  }
}

// MARK: - Private Method

private extension SearchViewController {
  
  /// 사파리 뷰 컨트롤러 초기화.
  private func makeSafariViewController(url: URL) -> SFSafariViewController {
    let config = SFSafariViewController.Configuration().then {
      $0.barCollapsingEnabled = true
      $0.entersReaderIfAvailable = true
    }
    let viewController = SFSafariViewController(url: url, configuration: config).then {
      $0.preferredBarTintColor = .main
      $0.dismissButtonStyle = .close
    }
    return viewController
  }
}
