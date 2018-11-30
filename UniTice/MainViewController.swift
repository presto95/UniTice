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

class MainViewController: UIViewController {

    private var posts: [Post] = []
    lazy private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didRefreshControlActivate(_:)), for: .valueChanged)
        return control
    }()
    lazy private var searchController: UISearchController? = {
        guard let searchResultController = storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController") as? SearchResultTableViewController else { return nil }
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = searchResultController
        definesPresentationContext = true
        return searchController
    }()
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "서울과학기술대학교"
        navigationItem.searchController = searchController
        registerForPreviewing(with: self, sourceView: tableView)
        kannaTest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 평점
    }
    
    @objc private func didRefreshControlActivate(_ sender: UIRefreshControl) {
        posts.removeAll()
        kannaTest()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func kannaTest() {
        DispatchQueue.global().async {
            guard let url = URL(string: "http://www.seoultech.ac.kr/service/info/notice/?bidx=4691&bnum=4691&allboard=false&page=\(1)&size=9&searchtype=1&searchtext=") else { return }
            guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
            // 글번호 / 타이틀 / 빈칸 / 조회수 / 날짜 / 작성자
            let rows = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td")
            // 링크
            let links = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td[@class='tit']//a/@href")
            for (index, element) in links.enumerated() {
                let numberIndex = index * 6
                let titleIndex = index * 6 + 1
                let dateIndex = index * 6 + 4
                let number = Int(rows[numberIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
                let title = rows[titleIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
                let date = rows[dateIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
                let link = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
                let post = Post(number: number, category: "", title: title, date: date, link: link)
                self.posts.append(post)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func safariViewController(at row: Int) -> SFSafariViewController {
        let link = posts[row].link
        guard let url = URL(string: "http://www.seoultech.ac.kr/service/info/notice\(link)") else { fatalError("wrong url format") }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
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
