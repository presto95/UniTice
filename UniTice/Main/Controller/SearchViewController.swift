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

    private lazy var keywords = (User.fetch()?.keywords)!
    
    private lazy var footerRefreshView: UIView = {
        let footerRefreshView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 32))
        footerRefreshView.backgroundColor = .white
        let footerActivityIndicator = UIActivityIndicatorView(style: .gray)
        footerActivityIndicator.hidesWhenStopped = true
        footerRefreshView.addSubview(footerActivityIndicator)
        footerActivityIndicator.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        return footerRefreshView
    }()
    
    private lazy var universityModel = University.generateModel()
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    private var footerActivityIndicator: UIActivityIndicatorView? {
        return footerRefreshView.subviews.last as? UIActivityIndicatorView
    }
    
    private var posts: [Post] = []
    
    private var page: Int = 1
    
    private var searchButtonHasClicked: Bool = false
    
    private var searchText: String = ""
    
    var category: (name: String, description: String)!
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "postCell")
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
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    private func requestPosts(searchText text: String) {
        footerActivityIndicator?.startAnimating()
        universityModel.requestPosts(inCategory: category, inPage: page, searchText: text) { posts in
            self.posts.append(contentsOf: posts.filter { $0.number != 0 })
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.footerActivityIndicator?.stopAnimating()
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
        let fullLink = universityModel.postURL(inCategory: category, link: post.link).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bookmark = Post(number: 0, title: post.title, date: post.date, link: fullLink)
        User.insertBookmark(bookmark)
        if let url = URL(string: fullLink) {
            present(safariViewController(url: url), animated: true)
        }
    }
}

extension SearchViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchButtonHasClicked {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.bounds.height {
                if !(footerActivityIndicator?.isAnimating ?? false) {
                    footerActivityIndicator?.startAnimating()
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
            let fullLink = universityModel.postURL(inCategory: category, link: post.link).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
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

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        posts.removeAll()
        searchButtonHasClicked = true
        searchText = searchBar.text ?? ""
        requestPosts(searchText: searchText)
    }
}
