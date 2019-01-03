//
//  SettingTableViewController.swift
//  UniTice
//
//  Created by Presto on 30/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI

class SettingTableViewController: UITableViewController {

    private var notificationHasGranted: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.isOn = !UserDefaults.standard.bool(forKey: "fold")
        control.addTarget(self, action: #selector(switchDidValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    private var switchIsOn: Bool {
        return switchControl.isOn
    }
    
    private let texts = [["상단 고정 게시물 펼치기"], ["학교 변경", "키워드 설정", "알림 설정"], ["문의하기", "앱 평가하기"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.notificationHasGranted = true
            } else {
                self.notificationHasGranted = false
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveEnterForegroundNotification(_:)), name: NSNotification.Name("willEnterForeground"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didReceiveEnterForegroundNotification(_ notification: Notification) {
        if let notificationHasGranted = notification.userInfo?["notificationHasGranted"] as? Bool {
            self.notificationHasGranted = notificationHasGranted
        }
    }
    
    @objc private func switchDidValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(false, forKey: "fold")
        } else {
            UserDefaults.standard.set(true, forKey: "fold")
        }
        tableView.reloadData()
    }
}

extension SettingTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = texts[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            cell.accessoryView = switchControl
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if switchIsOn {
                return "상단 고정 게시물이 펼쳐진 상태입니다."
            } else {
                return "상단 고정 게시물이 접혀진 상태입니다."
            }
        } else if section == 1 {
            if notificationHasGranted {
                return "알림이 활성화되어 있습니다."
            } else {
                return "알림이 비활성화되어 있습니다."
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
        case 1 where row == 0:
            let next = UIViewController.instantiate(from: "Setting", identifier: ChangeUniversityViewController.classNameToString)
            navigationController?.pushViewController(next, animated: true)
        case 1 where row == 1:
            let next = UIViewController.instantiate(from: "Setting", identifier: KeywordSettingViewController.classNameToString)
            navigationController?.pushViewController(next, animated: true)
        case 1 where row == 2:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case 2 where row == 0:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["yoohan95@gmail.com"])
                present(mail, animated: true)
            }
        case 2 where row == 1:
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/1447871519") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
