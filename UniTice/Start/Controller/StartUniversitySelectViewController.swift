//
//  StartUniversitySelectViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import MessageUI
import UIKit

import RxCocoa
import RxSwift

final class StartUniversitySelectViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  
  private var viewModel = StartUniversityViewModel()
  
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
    bindPickerViewItemTitles()
    bindPickerViewItemSelected()
  }
  
  func bindConfirmButton() {
    confirmButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        guard let `self` = self else { return }
        UIViewController
          .instantiate(from: "Start", identifier: StartKeywordRegisterViewController.classNameToString)
          .push(at: self)
        InitialInfo.shared.university = self.viewModel.selectedUniversity
      })
      .disposed(by: disposeBag)
  }
  
  func bindNoneButton() {
    noneButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        guard let `self` = self else { return }
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["yoohan95@gmail.com"])
        mailComposer.setSubject("[다연결] 우리 학교가 목록에 없어요.")
        mailComposer.setMessageBody("\n\n\n\n\n\n피드백 감사합니다.", isHTML: false)
        self.present(mailComposer, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
  func bindPickerViewItemTitles() {
    Observable
      .just(viewModel.universities)
      .bind(to: pickerView.rx.itemTitles) { _, element in
        return element.rawValue
      }
      .disposed(by: disposeBag)
  }
  
  func bindPickerViewItemSelected() {
    pickerView.rx
      .modelSelected(University.self)
      .map { $0.first }
      .subscribe(onNext: { [weak self] university in
        if let university = university {
          self?.viewModel.selectedUniversity = university
        }
      })
      .disposed(by: disposeBag)
  }
}

extension StartUniversitySelectViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
