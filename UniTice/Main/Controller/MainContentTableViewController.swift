//
//  MainContentTableViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SafariServices

class MainContentTableViewController: UITableViewController {

    private var posts: [Post] = []
    
    var pageIndex: Int!
    
    var universityModel: UniversityModel!
    
    var category: (name: String, description: String) {
        return universityModel?.categories[pageIndex] ?? ("", "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForPreviewing(with: self, sourceView: tableView)
        tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPosts()
    }
    
    private func requestPosts() {
        universityModel?.requestPosts(inCategory: category, inPage: 1, completion: { posts in
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    private func safariViewController(at row: Int) -> SFSafariViewController {
        let link = posts[row].link
        guard let url = URL(string: universityModel.postURL(inCategory: category, link: link)) else { fatalError("wrong url format") }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        config.entersReaderIfAvailable = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        viewController.dismissButtonStyle = .close
        return viewController
    }
}

extension MainContentTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        if posts.count == 0 {
            cell.textLabel?.showAnimatedGradientSkeleton()
            cell.detailTextLabel?.showAnimatedGradientSkeleton()
        } else {
            cell.textLabel?.hideSkeleton()
            cell.detailTextLabel?.hideSkeleton()
            cell.detailTextLabel?.backgroundColor = .clear
            let post = posts[indexPath.row]
            let weight: UIFont.Weight = post.number == 0 ? .bold : .regular
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: weight)
            cell.textLabel?.text = post.title
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
            cell.detailTextLabel?.text = post.date
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count == 0 ? 15 : posts.count
    }
}

extension MainContentTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        present(safariViewController(at: indexPath.row), animated: true)
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
        return UISwipeActionsConfiguration(actions: [])
    }
}

extension MainContentTableViewController: UIViewControllerPreviewingDelegate {
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

extension MainContentTableViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: category.description)
    }
}
