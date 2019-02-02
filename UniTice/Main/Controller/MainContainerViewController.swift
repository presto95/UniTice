//
//  MainBaseViewController.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import UserNotifications

import XLPagerTabStrip

final class MainContainerViewController: ButtonBarPagerTabStripViewController {
  
  private var universityModel: UniversityScrappable = UniversityModel.shared.universityModel {
    didSet {
      (navigationItem.leftBarButtonItem?.customView as? UILabel)?.text = universityModel.name
    }
  }
  
  override func viewDidLoad() {
    setupButtonBar()
    super.viewDidLoad()
    registerLocalNotification()
    setupUniversityLabel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    universityModel = UniversityModel.shared.universityModel
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
  
  @IBAction private func searchButtonDidTap(_ sender: UIBarButtonItem) {
    guard let next = UIViewController.instantiate(from: "Main", identifier: SearchViewController.classNameToString) as? SearchViewController else { return }
    next.category = (viewControllers(for: self)[currentIndex] as? MainContentTableViewController)?.category
    navigationController?.pushViewController(next, animated: true)
  }
}

extension MainContainerViewController {
  private func setupUniversityLabel() {
    let universityLabel = UILabel()
    universityLabel.text = universityModel.name
    universityLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    universityLabel.sizeToFit()
    let leftBarButtonItem = UIBarButtonItem(customView: universityLabel)
    navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
  }
  
  private func setupButtonBar() {
    settings.style.selectedBarHeight = 5
    settings.style.selectedBarBackgroundColor = .main
    settings.style.buttonBarBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    settings.style.buttonBarItemBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    settings.style.buttonBarItemTitleColor = .black
    settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
  }
  
  private func registerLocalNotification() {
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isGranted, error in
      if let error = error {
        fatalError(error.localizedDescription)
      }
      if !UserDefaults.standard.bool(forKey: "showsAlertIfPermissionDenied") {
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "오늘은 무슨 공지사항이 새로 올라왔을까요? 확인해 보세요."
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "localNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
          print(error?.localizedDescription ?? "")
        })
        if !isGranted {
          UIAlertController
            .alert(title: "", message: "알림을 받을 수 없습니다.\n설정에서 알림 권한을 설정할 수 있습니다.")
            .action(title: "확인")
            .present(to: self)
        }
      }
      UserDefaults.standard.set(true, forKey: "showsAlertIfPermissionDenied")
    }
  }
}
