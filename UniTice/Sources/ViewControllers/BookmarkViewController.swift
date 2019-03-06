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

/// 북마크 뷰 컨트롤러.
final class BookmarkViewController: UIViewController, StoryboardView {
  
  typealias Reactor = BookmarkViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  var dataSource: RxTableViewSectionedReloadDataSource<UTSection>!
  
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
    dataSource = RxTableViewSectionedReloadDataSource<UTSection>
      .init(configureCell: { dataSource, tableView, indexPath, data in
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        cell.textLabel?.attributedText
          = data.title.highlightKeywords(reactor.currentState.keywords)
        cell.detailTextLabel?.text = data.date
        return cell
      })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
    reactor.state.map { $0.bookmarks }
      .map { bookmarks -> [UTSection] in
        return bookmarks.map {
          UTSection(items: [UTSectionData(title: $0.title,
                                          date: $0.date,
                                          link: $0.link)])
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
}

// MARK: - Reactor Binding

private extension BookmarkViewController {
  
  
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

// MARK: - Private Method

private extension BookmarkViewController {
  
  func makeSafariViewController(at row: Int) -> SFSafariViewController {
    let bookmark = reactor?.currentState.bookmarks[row]
    guard let url = URL(string: bookmark?.link ?? "") else {
      fatalError("invalid url format")
    }
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
}
