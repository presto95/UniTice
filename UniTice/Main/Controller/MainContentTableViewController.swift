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
import SkeletonView
import Highlighter
import SafariServices

class MainContentTableViewController: UITableViewController {

    private var posts: [Post] = []
    
    private lazy var keywords = (User.fetch()?.keywords)!
    
    private var fixedPosts: [Post] {
        return posts.filter { $0.number == 0 }
    }
    
    private var standardPosts: [Post] {
        return posts.filter { $0.number != 0 }
    }
    
    private var isFixedNoticeFolded: Bool = false

    var categoryIndex: Int!
    
    var page: Int = 1
    
    var universityModel: UniversityModel!
    
    var category: (name: String, description: String) {
        return universityModel?.categories[categoryIndex] ?? ("", "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.description
        registerForPreviewing(with: self, sourceView: tableView)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefreshControlActivate(_:)), for: .valueChanged)
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "postCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if posts.isEmpty {
            requestPosts()
        }
    }
    
    @objc private func didRefreshControlActivate(_ sender: UIRefreshControl) {
        posts.removeAll()
        requestPosts()
        refreshControl?.endRefreshing()
    }
    
    private func requestPosts() {
        universityModel?.requestPosts(inCategory: category, inPage: page, completion: { posts in
            while posts.isEmpty {
                self.requestPosts()
                return
            }
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    private func safariViewController(url: URL) -> SFSafariViewController {
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
        if posts.isEmpty {
            tableView.allowsSelection = false
            cell.textLabel?.showAnimatedGradientSkeleton()
            cell.detailTextLabel?.showAnimatedGradientSkeleton()
        } else {
            tableView.allowsSelection = true
            cell.textLabel?.hideSkeleton()
            cell.detailTextLabel?.hideSkeleton()
            cell.detailTextLabel?.backgroundColor = .white
            if indexPath.section == 0 {
                if !fixedPosts.isEmpty {
                    let post = fixedPosts[indexPath.row]
                    cell.textLabel?.text = post.title
                    keywords.forEach { keyword in
                        cell.textLabel?.highlight(text: keyword, normal: nil, highlight: [
                            .foregroundColor: UIColor.purple,
                            .backgroundColor: UIColor.cyan,
                            .font: UIFont.systemFont(ofSize: 15, weight: .heavy)
                            ])
                        
                    }
                    cell.detailTextLabel?.text = post.date
                }
            } else {
                if !standardPosts.isEmpty {
                    let post = standardPosts[indexPath.row]
                    cell.textLabel?.text = post.title
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
                if posts.isEmpty {
                    return 5
                } else {
                    return fixedPosts.count
                }
            }
        } else if section == 1 {
            if posts.isEmpty {
                return 15
            } else {
                return standardPosts.count
            }
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
        let fullLink = universityModel.postURL(inCategory: category, link: post.link)
        let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLink)
        User.insertBookmark(bookmark)
        if let url = URL(string: fullLink) {
            present(safariViewController(url: url), animated: true)
        }
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
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 8))
            footerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
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
            return 8
        }
        return .leastNonzeroMagnitude
    }
}

extension MainContentTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            let post = indexPath.section == 0 ? fixedPosts[indexPath.row] : standardPosts[indexPath.row]
            let fullLink = universityModel.postURL(inCategory: category, link: post.link)
            if let url = URL(string: fullLink) {
                return safariViewController(url: url)
            }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension MainContentTableViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "postCell"
    }
}

extension MainContentTableViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: category.description)
    }
}
