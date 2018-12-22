//
//  MainBaseViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainContainerViewController: ButtonBarPagerTabStripViewController {
    
    private var universityModel: UniversityModel = University.generateModel()
    
    private lazy var searchController: UISearchController? = {
        guard let searchResultController = storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController") as? SearchResultTableViewController else { return nil }
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = searchResultController
        definesPresentationContext = true
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = universityModel.name
        navigationItem.searchController = searchController
        setupButtonBar()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var viewControllers = [UITableViewController]()
        for index in universityModel.categories.indices {
            let contentViewController = MainContentTableViewController()
            contentViewController.pageIndex = index
            contentViewController.universityModel = self.universityModel
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
