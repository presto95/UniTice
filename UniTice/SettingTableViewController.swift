//
//  SettingTableViewController.swift
//  UniTice
//
//  Created by Presto on 30/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import Carte
import MessageUI

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "설정"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch indexPath.section {
        case 0 where row == 0:
            let next = ChangeSchoolViewController()
            navigationController?.pushViewController(next, animated: true)
        case 0 where row == 1:
            let next = KeywordSettingViewController()
            navigationController?.pushViewController(next, animated: true)
        case 1 where row == 0:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["yoohan95@gmail.com"])
                present(mail, animated: true)
            }
        case 1 where row == 1:
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
