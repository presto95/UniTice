//
//  StartUniversitySelectViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import MessageUI

class StartUniversitySelectViewController: UIViewController {

    private let universities = University.allCases.sorted { $0.rawValue < $1.rawValue }
    
    @IBOutlet private weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    @IBOutlet private weak var noneButton: UIButton! {
        didSet {
            noneButton.addTarget(self, action: #selector(touchUpNoneButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var confirmButton: StartConfirmButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpNoneButton(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["yoohan95@gmail.com"])
            mail.setSubject("[다연결] 우리 학교가 목록에 없어요!")
            mail.setMessageBody("\n\n\n\n\n\n알려주셔서 감사합니다. 최대한 빨리 업데이트 하겠습니다.", isHTML: false)
            present(mail, animated: true, completion: nil)
        }
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        let universityIndex = pickerView.selectedRow(inComponent: 0)
        InitialInfo.shared.university = universities[universityIndex]
        let next = UIViewController.instantiate(from: "Start", identifier: StartKeywordRegisterViewController.classNameToString)
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc private func touchUpBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension StartUniversitySelectViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return universities.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension StartUniversitySelectViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return universities[row].rawValue
    }
}

extension StartUniversitySelectViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
