//
//  SettingTableViewController.swift
//  UniTice
//
//  Created by Presto on 30/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import Carte
import UserNotifications
import MessageUI

class SettingTableViewController: UITableViewController {

    private var notificationIsGranted: Bool = false
    
    private let texts = [["학교 변경", "키워드 설정", "알림 설정"], ["문의하기", "앱 평가하기"], ["오픈소스 라이센스"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.alertSetting != UNNotificationSetting.enabled {
                self.notificationIsGranted = false
            } else {
                self.notificationIsGranted = true
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension SettingTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = texts[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if notificationIsGranted {
                return "알림이 활성화되어 있습니다."
            } else {
                return "알림이 비활성화되어 있습니다. 키워드 알림을 받을 수 없습니다."
            }
        }
        return nil
    }
}

extension SettingTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch indexPath.section {
        case 0 where row == 0:
            let next = UIViewController.instantiate(from: "Setting", identifier: ChangeUniversityViewController.classNameToString)
            navigationController?.pushViewController(next, animated: true)
        case 0 where row == 1:
            let next = UIViewController.instantiate(from: "Setting", identifier: KeywordSettingViewController.classNameToString)
            navigationController?.pushViewController(next, animated: true)
        case 0 where row == 2:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case 1 where row == 0:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["yoohan95@gmail.com"])
                present(mail, animated: true)
            }
        case 1 where row == 1:
            // 앱 아이디 생성 후 가능
            break
        case 2 where row == 0:
            let controller: CarteViewController = {
                let controller = CarteViewController(style: .plain)
                controller.items.sort { $0.name < $1.name }
                return controller
            }()
            navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
