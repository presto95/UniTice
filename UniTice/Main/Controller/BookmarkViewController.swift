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
import RxSwift

final class BookmarkViewController: UIViewController, StoryboardView {
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private let universityModel = UniversityModel.shared.universityModel
  
  private lazy var keywords = (User.fetch()?.keywords)!
  
  private var bookmarks = User.fetch()?.bookmarks
  
  @IBOutlet private weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: BookmarkViewReactor) {
    reactor.state.map { $0.bookmarks }
      .distinctUntilChanged()
      .bind(to: tableView.rx.items(cellIdentifier: "postCell", cellType: PostCell.self)) { row, element, cell in
        cell.textLabel?.attributedText = element.title.highlightKeywords(reactor.currentState.keywords)
        cell.detailTextLabel?.text = element.date
      }
      .disposed(by: disposeBag)
    tableView.rx.itemSelected.asObservable()
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.safariViewController(at: indexPath.row).present(to: self)
      })
      .disposed(by: disposeBag)
  }
  
  private func setup() {
    title = "북마크"
    registerForPreviewing(with: self, sourceView: tableView)
    //tableView.delegate = self
    //tableView.dataSource = self
    tableView.emptyDataSetSource = self
    //tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
  }
  
  private func safariViewController(at row: Int) -> SFSafariViewController {
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
  //
  //  func tableView(_ tableView: UITableView,
  //                 canEditRowAt indexPath: IndexPath) -> Bool {
  //    return true
  //  }
  //
  //  func tableView(_ tableView: UITableView,
  //                 commit editingStyle: UITableViewCell.EditingStyle,
  //                 forRowAt indexPath: IndexPath) {
  //    if editingStyle == .delete {
  //      if let bookmark = bookmarks?[indexPath.row] {
  //        User.removeBookmark(bookmark)
  //        tableView.deleteRows(at: [indexPath], with: .automatic)
  //      }
  //    }
  //  }
}

// MARK: - Force Touch

extension BookmarkViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    if let indexPath = tableView.indexPathForRow(at: location) {
      return safariViewController(at: indexPath.row)
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
