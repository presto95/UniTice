//
//  MainBaseViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import UserNotifications

class MainContainerViewController: ButtonBarPagerTabStripViewController {
    
    private var universityModel: UniversityModel = University.generateModel() {
        didSet {
            navigationItem.title = universityModel.name
        }
    }
    
//    private lazy var searchController: UISearchController? = {
//        guard let searchResultController = storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController") as? SearchResultTableViewController else { return nil }
//        let searchController = UISearchController(searchResultsController: searchResultController)
//        searchController.searchBar.placeholder = "검색"
//        searchController.searchResultsUpdater = searchResultController
//        definesPresentationContext = true
//        return searchController
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.searchController = searchController
        setupButtonBar()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isGranted, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            if !isGranted {
                // 알림 권한을 주어야 키워드 알림을 받을 수 있다는 커스텀 얼러트 띄우기
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        universityModel = University.generateModel()
        reloadPagerTabStripView()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var viewControllers = [UITableViewController]()
        for index in universityModel.categories.indices {
            let contentViewController = MainContentTableViewController()
            contentViewController.categoryIndex = index
            contentViewController.universityModel = universityModel
            viewControllers.append(contentViewController)
        }
        return viewControllers
    }
    
    private func setupButtonBar() {
        settings.style.selectedBarHeight = 1
        settings.style.selectedBarBackgroundColor = .black
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
}
