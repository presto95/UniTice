//
//  StartUniversitySelectViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa

class StartUniversitySelectViewController: UIViewController {
    
    private let disposeBag = DisposeBag()

    private lazy var universities = University.allCases.sorted { $0.rawValue < $1.rawValue }
    
    @IBOutlet private weak var pickerView: UIPickerView!
    
    @IBOutlet private weak var noneButton: UIButton!
    
    @IBOutlet private weak var confirmButton: StartConfirmButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
}

private extension StartUniversitySelectViewController {
    func bindUI() {
        bindConfirmButton()
        bindNoneButton()
        bindPickerViewTitles()
    }
    
    func bindConfirmButton() {
        confirmButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                let universityIndex = self.pickerView.selectedRow(inComponent: 0)
                InitialInfo.shared.university = self.universities[universityIndex]
                let next = UIViewController.instantiate(from: "Start", identifier: StartKeywordRegisterViewController.classNameToString)
                self.navigationController?.pushViewController(next, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bindNoneButton() {
        noneButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["yoohan95@gmail.com"])
                    mail.setSubject("[다연결] 우리 학교가 목록에 없어요!")
                    mail.setMessageBody("\n\n\n\n\n\n피드백 감사합니다.", isHTML: false)
                    self.present(mail, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindPickerViewTitles() {
        Observable
            .just(universities)
            .bind(to: pickerView.rx.itemTitles) { _, element in
                return element.rawValue
            }
            .disposed(by: disposeBag)
    }
}

extension StartUniversitySelectViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
