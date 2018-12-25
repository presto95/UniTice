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
            (navigationItem.leftBarButtonItem?.customView as? UILabel)?.text = universityModel.name
        }
    }
    
    override func viewDidLoad() {
        setupButtonBar()
        super.viewDidLoad()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isGranted, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            if !isGranted {
                // 알림 권한 허용 대화상자 띄울 위치는?
            }
        }
        setupUniversityLabel()
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
    
    private func setupUniversityLabel() {
        let universityLabel = UILabel()
        universityLabel.text = universityModel.name
        universityLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        let leftBarButtonItem = UIBarButtonItem(customView: universityLabel)
        navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
    }
    
    private func setupButtonBar() {
        settings.style.selectedBarHeight = 5
        settings.style.selectedBarBackgroundColor = .purple
        settings.style.buttonBarBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
}
