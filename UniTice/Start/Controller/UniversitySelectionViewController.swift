//
//  StartUniversitySelectViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import MessageUI
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class UniversitySelectionViewController: UIViewController, StoryboardView {
  
  var disposeBag = DisposeBag()
  
  @IBOutlet private weak var pickerView: UIPickerView!
  
  @IBOutlet private weak var noticeButton: UIButton!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    confirmButton.type = .next
  }
  
  func bind(reactor: UniversitySelectionViewReactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
  
  private func formMailComposeViewController() -> UIViewController {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients(["yoohan95@gmail.com"])
    mailComposer.setSubject("[다연결] 우리 학교가 목록에 없어요.")
    mailComposer.setMessageBody("\n\n\n\n\n\n피드백 감사합니다.", isHTML: false)
    return mailComposer
  }
}

// MARK: - Reactor Binding

private extension UniversitySelectionViewController {
  
  func bindAction(_ reactor: UniversitySelectionViewReactor) {
    // 확인 버튼 바인딩
    confirmButton.rx.tap
      .map { Reactor.Action.touchUpConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    // 알려주세요 버튼 바인딩
    noticeButton.rx.tap
      .map { Reactor.Action.touchUpNoticeButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: UniversitySelectionViewReactor) {
    // 확인 버튼 눌렸는지에 대한 상태 바인딩
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isSelected in
        guard let self = self else { return }
        if isSelected {
          let keywordRegisterViewController
            = StoryboardScene.Start.startKeywordRegisterViewController.instantiate()
          keywordRegisterViewController.reactor = KeywordRegisterReactor()
          keywordRegisterViewController.push(at: self)
        }
      })
      .disposed(by: disposeBag)
    // 알려주세요 버튼 눌렸는지에 대한 상태 바인딩
    reactor.state.map { $0.isInfoButtonSelected }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isSelected in
        guard let self = self else { return }
        if isSelected {
          let mailComposer = self.formMailComposeViewController()
          self.present(mailComposer, animated: true, completion: nil)
        }
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    // 피커 뷰 데이터 소스 바인딩
    Observable.just(University.allCases)
      .bind(to: pickerView.rx.itemTitles) { _, element in
        return element.rawValue
      }
      .disposed(by: disposeBag)
    // 피커 뷰 셀렉션 바인딩
    pickerView.rx.modelSelected(University.self)
      .map { $0.first }
      .subscribe(onNext: { university in
        if let university = university {
          InitialInfo.shared.university = university
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - MFMailComposeViewControllerDelegate 구현

extension UniversitySelectionViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
