//
//  BookmarkViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 15/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

/// The bookmark view controller.
final class BookmarkViewController: UIViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = BookmarkViewReactor
  
  typealias DataSource = RxTableViewSectionedReloadDataSource<UTSection>
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private var dataSource: DataSource!
  
  @IBOutlet private weak var tableView: UITableView!
  
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
    tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
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
        let items = bookmarks.map {
          return UTSectionData(title: $0.title, date: $0.date, link: $0.link)
        }
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
    if let indexPath = tableView.indexPathForRow(at: location) {
      let url = URL(string: "")!
      return makeSafariViewController(url: url)
      //return makeSafariViewController(at: indexPath.row)
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
    dataSource = DataSource(configureCell: { _, tableView, indexPath, bookmark in
      let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
      cell.textLabel?.attributedText = .init(string: bookmark.title)
      cell.detailTextLabel?.text = bookmark.date
      return cell
    })
    dataSource.canEditRowAtIndexPath = { _, _ in true }
  }
  
  func bindUI() {
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
        let url = URL(string: "")!
        self.makeSafariViewController(url: url).present(to: self)
        //self.makeSafariViewController(at: indexPath.row).present(to: self)
      })
      .disposed(by: disposeBag)
  }
//
//  func makeSafariViewController(at row: Int) -> SFSafariViewController {
//    let bookmark = reactor?.currentState.bookmarks[row]
//    guard let url = URL(string: bookmark?.link ?? "") else {
//      fatalError("invalid url format")
//    }
//    let config = SFSafariViewController.Configuration().then {
//      $0.barCollapsingEnabled = true
//      $0.entersReaderIfAvailable = true
//    }
//    let viewController = SFSafariViewController(url: url, configuration: config).then {
//      $0.preferredControlTintColor = .main
//      $0.dismissButtonStyle = .close
//    }
//    return viewController
//  }
}

extension BookmarkViewController: SafariViewControllerPresentable { }
