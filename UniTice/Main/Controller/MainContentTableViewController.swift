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

    private var posts: [Post] = []
    
    private var fixedPosts: [Post]? {
        return posts.filter { $0.number == 0 }
    }
    
    private var standardPosts: [Post]? {
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
        tableView.separatorStyle = .none
        tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPosts()
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
    
    private func safariViewController(at row: Int) -> SFSafariViewController {
        let link = posts[row].link
        guard let url = URL(string: universityModel.postURL(inCategory: category, link: link)) else { fatalError("invalid url format") }
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
            //cell.textLabel?.showAnimatedGradientSkeleton()
            //cell.detailTextLabel?.showAnimatedGradientSkeleton()
        } else {
            tableView.allowsSelection = true
            cell.textLabel?.hideSkeleton()
            cell.detailTextLabel?.hideSkeleton()
            if indexPath.section == 0 {
                let post = fixedPosts?[indexPath.row]
                cell.textLabel?.text = post?.title
                cell.detailTextLabel?.text = post?.date
            } else {
                let post = standardPosts?[indexPath.row]
                cell.textLabel?.text = post?.title
                cell.detailTextLabel?.text = post?.date
            }
        }
//        if posts.count == 0 {
//            tableView.allowsSelection = false
//            cell.textLabel?.showAnimatedGradientSkeleton()
//            cell.detailTextLabel?.showAnimatedGradientSkeleton()
//        } else {
//            tableView.allowsSelection = true
//            cell.textLabel?.hideSkeleton()
//            cell.detailTextLabel?.hideSkeleton()
//            cell.detailTextLabel?.backgroundColor = .clear
//            let post = posts[indexPath.row]
//            let weight: UIFont.Weight = post.number == 0 ? .bold : .regular
//            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: weight)
//            cell.textLabel?.text = post.title
//            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
//            cell.detailTextLabel?.text = post.date
//        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (isFixedNoticeFolded ? 0 : fixedPosts?.count ?? 5) : (standardPosts?.count ?? 15)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension MainContentTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 북마크에 저장
        present(safariViewController(at: indexPath.row), animated: true)
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
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 2))
            footerView.backgroundColor = .white
            let label = UILabel(frame: .zero)
            label.backgroundColor = .black
            label.text = nil
            footerView.addSubview(label)
            label.snp.makeConstraints { maker in
                maker.leading.equalToSuperview().offset(16)
                maker.trailing.equalToSuperview().offset(-16)
                maker.centerY.equalToSuperview()
                maker.height.equalTo(1)
            }
            return footerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }
        return .leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 2
        }
        return .leastNonzeroMagnitude
    }
//
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let action = UIContextualAction(style: .normal, title: "북마크") { action, view, isPerformed in
//            // 저장
//            print("북마크")
//        }
//        action.backgroundColor = .orange
//        let config = UISwipeActionsConfiguration(actions: [action])
//        config.performsFirstActionWithFullSwipe = false
//        return config
//    }
//
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        return UISwipeActionsConfiguration(actions: [])
//    }
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
