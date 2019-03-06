//
//  BookmarkViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 15/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import SafariServices
import UIKit

import DZNEmptyDataSet
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import RxViewController

final class BookmarkViewController: UIViewController, StoryboardView {
  
  typealias Reactor = BookmarkViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private let universityModel = UniversityModel.shared.universityModel
  
  private lazy var keywords = (User.fetch()?.keywords)!
  
  private var bookmarks = User.fetch()?.bookmarks
  
  var dataSource: RxTableViewSectionedReloadDataSource<BookmarkSection>!
  
  @IBOutlet private weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: Reactor) {
    rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    dataSource = RxTableViewSectionedReloadDataSource<BookmarkSection>
      .init(configureCell: { dataSource, tableView, indexPath, data in
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        cell.textLabel?.attributedText = data.title.highlightKeywords(reactor.currentState.keywords)
        cell.detailTextLabel?.text = data.date
        return cell
      })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
    reactor.state.map { $0.bookmarks }
      .map { bookmarks -> [BookmarkSection] in
        return bookmarks.map {
          BookmarkSection(items: [BookmarkSectionData(title: $0.title, date: $0.date)])
        }
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.makeSafariViewController(at: indexPath.row).present(to: self)
      })
      .disposed(by: disposeBag)
    tableView.rx.itemDeleted.asObservable()
      .map { Reactor.Action.deleteBookmark($0.item) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  private func setup() {
    title = "북마크"
    registerForPreviewing(with: self, sourceView: tableView)
    tableView.emptyDataSetSource = self
    tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
  }
  
  private func makeSafariViewController(at row: Int) -> SFSafariViewController {
    let bookmark = bookmarks?[row]
    guard let url = URL(string: bookmark?.link ?? "") else {
      fatalError("invalid url format")
    }
    let config = SFSafariViewController.Configuration()
    config.barCollapsingEnabled = true
    config.entersReaderIfAvailable = true
    let viewController = SFSafariViewController(url: url, configuration: config)
    viewController.preferredControlTintColor = .main
    viewController.dismissButtonStyle = .close
    return viewController
  }
}

// MARK: - UITableViewDelegate 구현

extension BookmarkViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let action
      = UIContextualAction(style: .destructive,
                           title: "삭제") { [weak self, weak reactor] _, _, _ in
                            guard let reactor = reactor else { return }
                            guard let self = self else { return }
                            let bookmark = reactor.currentState.bookmarks[indexPath.row]
                            User.removeBookmark(bookmark)
                            Observable
                              .just(Void())
                              .map { Reactor.Action.deleteBookmark(indexPath.row) }
                              .bind(to: reactor.action)
                              .disposed(by: self.disposeBag)
    }
    let config = UISwipeActionsConfiguration(actions: [action])
    return config
  }
}

// MARK: - UIViewControllerPreviewDelegate 구현

extension BookmarkViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    if let indexPath = tableView.indexPathForRow(at: location) {
      return makeSafariViewController(at: indexPath.row)
    }
    return nil
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit
    viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true, completion: nil)
  }
}

// MARK: - DZNEmptyDataSetSource 구현

extension BookmarkViewController: DZNEmptyDataSetSource {
  
  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "기록 없음")
  }
}
