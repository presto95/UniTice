//
//  BookmarkViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 15/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

/// The bookmark view controller.
final class BookmarkViewController: UIViewController,
                                    StoryboardView,
                                    SafariPresentable {
  
  // MARK: Typealias
  
  typealias Reactor = BookmarkViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<UTSection>
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var dataSource: DataSource!
  
  private let cellIdentifier = "postCell"
  
  @IBOutlet private weak var tableView: UITableView!
  
  // MARK: Method
  
  override func viewDidLoad() {
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
    title = "북마크"
    registerForPreviewing(with: self, sourceView: tableView)
    tableView.do {
      $0.backgroundColor = .groupTableViewBackground
      $0.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
      $0.separatorColor = .main
      $0.register(PostCell.self, forCellReuseIdentifier: cellIdentifier)
    }
  }
}

// MARK: - Reactor Binding

private extension BookmarkViewController {
  
  func bindAction(_ reactor: Reactor) {
    Observable.just(Void())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    tableView.rx.itemDeleted
      .map { Reactor.Action.deleteBookmark(index: $0.item) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.bookmarks }
      .map { bookmarks in
        let items = bookmarks.map { UTSectionData(title: $0.title, date: $0.date, link: $0.link) }
        return [UTSection(items: items)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}

// MARK: - UIViewControllerPreviewDelegate 구현

extension BookmarkViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let reactor = reactor else { return nil }
    if let indexPath = tableView.indexPathForRow(at: location) {
      let bookmark = reactor.currentState.bookmarks[indexPath.item]
      if let url = URL(string: bookmark.link) {
        return makeSafariViewController(url: url)
      }
    }
    return nil
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true, completion: nil)
  }
}

// MARK: - Private Method

private extension BookmarkViewController {
  
  func bindDataSource() {
    let keywords = reactor?.currentState.keywords ?? []
    dataSource = DataSource(configureCell: { _, tableView, indexPath, bookmark in
      return tableView
        .dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath).then {
          $0.textLabel?.attributedText = bookmark.title.highlightKeywords(keywords)
          $0.detailTextLabel?.text = bookmark.date
      }
    })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self, weak reactor] indexPath in
        guard let self = self, let reactor = reactor else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
        let bookmark = reactor.currentState.bookmarks[indexPath.item]
        if let url = URL(string: bookmark.link) {
          self.makeSafariViewController(url: url).present(to: self)
        }
      })
      .disposed(by: disposeBag)
  }
}
