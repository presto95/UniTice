//
//  SearchResultTableViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 15/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SafariServices

class SearchResultTableViewController: UITableViewController {

    private var results: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("result table view did load")
    }
    
    private func safariViewController(at row: Int) -> SFSafariViewController {
        let link = results[row].link
        guard let url = URL(string: "http://www.seoultech.ac.kr/service/info/notice\(link)") else { fatalError("wrong url format") }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        viewController.dismissButtonStyle = .close
        return viewController
    }
}

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "dummyTitle"
        cell.detailTextLabel?.text = "dummyDetailText"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "북마크") { action, view, isPerformed in
            // 저장
            print("북마크")
        }
        action.backgroundColor = .orange
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [])
        return config
    }
}

extension SearchResultTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        tableView.reloadSections(IndexSet(0...0), with: .automatic)
    }
}

extension SearchResultTableViewController: UIViewControllerPreviewingDelegate {
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

extension SearchResultTableViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "검색 결과 없음")
    }
}

extension SearchResultTableViewController: DZNEmptyDataSetDelegate {
    
}
