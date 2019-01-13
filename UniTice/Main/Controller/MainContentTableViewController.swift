//
//  MainContentTableViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit
import SafariServices

class MainContentTableViewController: UITableViewController {

    private lazy var keywords = (User.fetch()?.keywords)!

    private var posts: [Post] = []

    private var fixedPosts: [Post] {
        get {
            return posts.filter { $0.number == 0 }
        }
        set {
            posts.append(contentsOf: newValue)
        }
        
    }
    
    private var standardPosts: [Post] {
        return posts.filter { $0.number != 0 }
    }
    
    private var isFixedNoticeFolded = UserDefaults.standard.bool(forKey: "fold")

    var categoryIndex: Int!
    
    var page: Int = 1 {
        didSet {
            requestPosts()
        }
    }
    
    var universityModel: UniversityScrappable!
    
    var category: (identifier: String, description: String) {
        return universityModel?.categories[categoryIndex] ?? ("", "")
    }
    
    private lazy var footerRefreshView = FooterRefreshView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 32))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.description
        registerForPreviewing(with: self, sourceView: tableView)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefreshControlActivate(_:)), for: .valueChanged)
        tableView.tableFooterView = footerRefreshView
        tableView.backgroundColor = .groupTableViewBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.separatorColor = .main
        tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if posts.isEmpty {
            requestPosts()
        }
    }
    
    @objc private func didRefreshControlActivate(_ sender: UIRefreshControl) {
        posts.removeAll()
        page = 1
        refreshControl?.endRefreshing()
    }
    
    private func requestPosts() {
        footerRefreshView.activate()
        universityModel?.requestPosts(inCategory: category, inPage: page, searchText: "") { posts, error in
            if let error = error {
                UIAlertController.presentErrorAlert(error, to: self)
            }
            guard let posts = posts else { return }
            if self.page == 1 {
                self.posts.append(contentsOf: posts)
            } else {
                if posts.first?.title == self.fixedPosts.first?.title {
                    self.posts.append(contentsOf: posts.filter { $0.number != 0 })
                } else {
                    self.posts.append(contentsOf: posts)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.footerRefreshView.deactivate()
            }
        }
    }
    
    private func safariViewController(url: URL) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        config.entersReaderIfAvailable = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        viewController.preferredControlTintColor = .main
        viewController.dismissButtonStyle = .close
        return viewController
    }
}

extension MainContentTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.bounds.height {
            if !footerRefreshView.isLoading {
                footerRefreshView.activate()
                page += 1
            }
        }
    }
}

extension MainContentTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        if posts.isEmpty {
            tableView.allowsSelection = false
        } else {
            tableView.allowsSelection = true
            if indexPath.section == 0 {
                if !fixedPosts.isEmpty {
                    let post = fixedPosts[indexPath.row]
                    cell.textLabel?.attributedText = post.title.highlightKeywords(Array(keywords))
                    cell.detailTextLabel?.text = post.date
                }
            } else {
                if !standardPosts.isEmpty {
                    let post = standardPosts[indexPath.row]
                    cell.textLabel?.attributedText = post.title.highlightKeywords(Array(keywords))
                    cell.detailTextLabel?.text = post.date
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isFixedNoticeFolded {
                return 0
            } else {
                return fixedPosts.count
            }
        } else if section == 1 {
            return standardPosts.count
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension MainContentTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = indexPath.section == 0 ? fixedPosts[indexPath.row] : standardPosts[indexPath.row]
        let fullLink = universityModel.postURL(inCategory: category, uri: post.link)
        let fullLinkString = fullLink.absoluteString
        let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
        User.insertBookmark(bookmark)
        present(safariViewController(url: fullLink), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerView = UIView.instantiate(fromXib: "MainNoticeHeaderView") as? MainNoticeHeaderView else { return nil }
            headerView.state = isFixedNoticeFolded
            headerView.foldingHandler = {
                self.isFixedNoticeFolded = !self.isFixedNoticeFolded
                self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
            }
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 5))
            footerView.backgroundColor = .main
            return footerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 48
        }
        return .leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return .leastNonzeroMagnitude
    }
}

extension MainContentTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            let post = indexPath.section == 0 ? fixedPosts[indexPath.row] : standardPosts[indexPath.row]
            do {
                let fullLink = universityModel.postURL(inCategory: category, uri: post.link)
                let fullLinkString = fullLink.absoluteString
                print(fullLinkString)
                let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
                User.insertBookmark(bookmark)
                return safariViewController(url: fullLink)
            } catch {
                UIAlertController.presentErrorAlert(error, to: self)
            }
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
