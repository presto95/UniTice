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

final class BookmarkViewController: UIViewController {
  
  private let universityModel = UniversityModel.shared.universityModel
  
  private lazy var keywords = (User.fetch()?.keywords)!
  
  private var bookmarks = User.fetch()?.bookmarks
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
      tableView.emptyDataSetSource = self
      tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "북마크"
    registerForPreviewing(with: self, sourceView: tableView)
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

extension BookmarkViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
    let bookmark = bookmarks?[indexPath.row]
    cell.textLabel?.attributedText = bookmark?.title.highlightKeywords(Array(keywords))
    cell.detailTextLabel?.text = bookmark?.date
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return bookmarks?.count ?? 0
  }
}

extension BookmarkViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    present(safariViewController(at: indexPath.row), animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      if let bookmark = bookmarks?[indexPath.row] {
        User.removeBookmark(bookmark)
        tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }
  }
}

extension BookmarkViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    if let indexPath = tableView.indexPathForRow(at: location) {
      return safariViewController(at: indexPath.row)
    }
    return nil
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true, completion: nil)
  }
}

extension BookmarkViewController: DZNEmptyDataSetSource {
  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "기록 없음")
  }
}
