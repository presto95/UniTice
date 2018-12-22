//
//  MainViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 10/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import Kanna
import StoreKit
import SafariServices
import SkeletonView
import XLPagerTabStrip
import UserNotifications

class MainViewController: UIViewController {

    private var posts: [Post] = []
    
    private var universityModel: UniversityModel = University.generateModel()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didRefreshControlActivate(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var searchController: UISearchController? = {
        guard let searchResultController = storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController") as? SearchResultTableViewController else { return nil }
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = searchResultController
        definesPresentationContext = true
        return searchController
    }()
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = universityModel.name
        navigationItem.searchController = searchController
        registerForPreviewing(with: self, sourceView: tableView)
        requestPosts()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isGranted, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            if !isGranted {
                // 알림 권한을 줘야 키워드 알림을 받을 수 있다는 커스텀 얼러트 띄우기
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        universityModel = University.generateModel()
    }

//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let viewControllers = [UITableViewController]()
//        university.categories.forEach { category in
//            let tableViewController = UITableViewController()
//
//
//        }
//        return []
//    }
    
    private func requestPosts() {
        universityModel.requestPosts(inCategory: universityModel.categories[0], inPage: 1) { posts in
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func didRefreshControlActivate(_ sender: UIRefreshControl) {
        posts.removeAll()
        requestPosts()
        refreshControl.endRefreshing()
    }
    
    private func safariViewController(at row: Int) -> SFSafariViewController {
        let link = posts[row].link
        guard let url = URL(string: universityModel.postURL(inCategory: universityModel.categories[0], link: link)) else { fatalError("wrong url format") }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        config.entersReaderIfAvailable = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        viewController.dismissButtonStyle = .close
        return viewController
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count == 0 ? 15 : posts.count
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        present(safariViewController(at: indexPath.row), animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "북마크") { action, view, isPerformed in
            // 저장
            print("북마크")
        }
        action.backgroundColor = .orange
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [])
        return config
    }
}

extension MainViewController: UIViewControllerPreviewingDelegate {
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

extension MainViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cell"
    }
}
