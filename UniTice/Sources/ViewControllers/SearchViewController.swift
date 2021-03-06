//
//  SearchViewController.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

/// The search view controller.
final class SearchViewController: UIViewController, StoryboardView, SafariPresentable {
  
  // MARK: Typealias
  
  typealias Reactor = SearchViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<UTSection>
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  /// The data source object for the table view.
  private var dataSource: DataSource!
  
  /// The cell identifier.
  private let cellIdentifier = "postCell"
  
  /// The header view.
  private let headerView = UIView()
  
  /// The footer view representing the refreshing status.
  private let footerRefreshView
    = FooterLoadingView(frame: CGRect(x: 0,
                                      y: 0,
                                      width: UIScreen.main.bounds.width,
                                      height: 32)).then {
                                        $0.reactor = FooterLoadingViewReactor()
  }
  
  /// The search controller embedded in the view contorller.
  private lazy var searchController = UISearchController(searchResultsController: nil).then {
    $0.searchBar.placeholder = "제목"
    $0.hidesNavigationBarDuringPresentation = false
  }
  
  /// The search bar of the search controller.
  private var searchBar: UISearchBar {
    return searchController.searchBar
  }
  
  /// The table view.
  @IBOutlet private weak var tableView: UITableView!
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchController.isActive = true
  }
  
  func bind(reactor: Reactor) {
    bindDataSource(reactor)
    bindUI()
    bindAction(reactor)
    bindState(reactor)
  }
  
  private func setup() {
    guard let reactor = reactor else { return }
    let currentCategory = reactor.currentState.category
    registerForPreviewing(with: self, sourceView: tableView)
    headerView.bounds.size.height = 48
    let headerLabel = UILabel().then {
      $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
      $0.text = "🔍검색 카테고리 : \(currentCategory.description)"
    }
    headerView.addSubview(headerLabel)
    headerLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    tableView.do {
      $0.backgroundColor = .groupTableViewBackground
      $0.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
      $0.separatorColor = .main
      $0.tableHeaderView = headerView
      $0.tableFooterView = footerRefreshView
      $0.register(PostCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    definesPresentationContext = true
    navigationItem.titleView = searchController.searchBar
  }
}

// MARK: - Reactor Binding

private extension SearchViewController {
  
  func bindAction(_ reactor: Reactor) {
    searchController.rx.didPresent
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    searchBar.rx.text
      .map { Reactor.Action.updateSearchText($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    searchBar.rx.searchButtonClicked
      .map { Reactor.Action.search }
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
      .filter { _ in reactor.currentState.hasSearched }
      .filter { _ in !reactor.currentState.isLoading }
      .map { _ in Reactor.Action.scroll }
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
    reactor.state.map { $0.posts }
      .map { posts -> [UTSection] in
        let items = posts.map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
        return [.init(items: items)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    reactor.state.map { $0.isPresented }
      .distinctUntilChanged()
      .filter { $0 }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.searchBar.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .map { FooterLoadingViewReactor.Action.loading($0) }
      .bind(to: footerRefreshView.reactor!.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension SearchViewController {
  
  func bindDataSource(_ reactor: Reactor) {
    dataSource = .init(configureCell: { _, tableView, indexPath, sectionData in
      let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
      if case let postCell as PostCell = cell {
        postCell.reactor = PostCellReactor(sectionData: sectionData,
                                           keywords: [])
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
    searchBar.rx.searchButtonClicked
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self, weak reactor] _ in
        guard let self = self, let reactor = reactor else { return }
        self.searchController.isActive = false
        let text = reactor.currentState.searchText
        self.searchBar.text = text
        Observable.just(text)
          .map { Reactor.Action.updateSearchText($0) }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func makeBookmark(at indexPath: IndexPath, state: Reactor.State) -> Post? {
    let post = state.posts[indexPath.item]
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

// MARK: - Conforming UIViewControllerPreviewingDelegate

extension SearchViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let reactor = reactor else { return nil }
    if let indexPath = tableView.indexPathForRow(at: location) {
      let currentState = reactor.currentState
      let post = currentState.posts[indexPath.item]
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
