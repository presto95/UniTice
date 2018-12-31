//
//  SearchViewController.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit
import SafariServices

class SearchViewController: UIViewController {
    
    private lazy var footerRefreshView = FooterRefreshView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 32))
    
    private lazy var universityModel = University.generateModel()
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    private var posts: [Post] = []
    
    private var page: Int = 1
    
    private var searchButtonHasClicked: Bool = false
    
    private var searchText: String = ""
    
    var category: (identifier: String, description: String)!
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForPreviewing(with: self, sourceView: tableView)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 48))
        let label = UILabel()
        label.text = "검색 카테고리 : \(category.description)"
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        headerView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerRefreshView
        searchController.searchBar.placeholder = "제목"
        searchController.delegate = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }

    private func requestPosts(searchText text: String) {
        footerRefreshView.activate()
        universityModel.requestPosts(inCategory: category, inPage: page, searchText: text) { posts, error in
            if let error = error {
                UIAlertController.presentErrorAlert(error, to: self)
                return
            }
            guard let posts = posts else { return }
            self.posts.append(contentsOf: posts.filter { $0.number != 0 })
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
        viewController.preferredControlTintColor = .purple
        viewController.dismissButtonStyle = .close
        return viewController
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.date
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        do {
            let fullLink = try universityModel.postURL(inCategory: category, uri: post.link)
            let fullLinkString = fullLink.absoluteString
            let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLinkString)
            User.insertBookmark(bookmark)
            present(safariViewController(url: fullLink), animated: true)
        } catch {
            UIAlertController.presentErrorAlert(error, to: self)
        }
    }
}

extension SearchViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchButtonHasClicked {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.bounds.height {
                if !footerRefreshView.isLoading {
                    footerRefreshView.activate()
                    page += 1
                    requestPosts(searchText: searchText)
                }
            }
        }
    }
}

extension SearchViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            let post = posts[indexPath.row]
            do {
                let fullLink = try universityModel.postURL(inCategory: category, uri: post.link)
                let fullLinkString = fullLink.absoluteString
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

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchController.isActive = false
        }
        posts.removeAll()
        searchButtonHasClicked = true
        searchText = searchBar.text ?? ""
        requestPosts(searchText: searchText)
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
}
