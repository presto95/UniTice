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
import Then

final class UniversitySelectionViewController: UIViewController, StoryboardView {
  
  var disposeBag = DisposeBag()
  
  @IBOutlet private weak var pickerView: UIPickerView!
  
  @IBOutlet private weak var noticeButton: UIButton!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: UniversitySelectionViewReactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
  
  private func setup() {
    confirmButton.type = .next
  }
}

// MARK: - Reactor Binding

private extension UniversitySelectionViewController {
  
  /// 리액터 액션 바인딩.
  func bindAction(_ reactor: UniversitySelectionViewReactor) {
    // 확인 버튼 바인딩
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    // 알려주세요 버튼 바인딩
    noticeButton.rx.tap
      .map { Reactor.Action.inquiry }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  /// 리액터 상태 바인딩.
  func bindState(_ reactor: UniversitySelectionViewReactor) {
    // 확인 버튼 눌렸는지에 대한 상태 바인딩
    reactor.state.map { $0.isPresentingNextScene }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let keywordRegisterViewController
          = StoryboardScene.Start.startKeywordRegisterViewController.instantiate()
        keywordRegisterViewController.reactor = KeywordRegisterViewReactor()
        keywordRegisterViewController.push(at: self)
      })
      .disposed(by: disposeBag)
//    reactor.state.map { $0.isConfirmButtonSelected }
//      .distinctUntilChanged()
//      .filter { $0 }
//      .subscribe(onNext: { [weak self] _ in
//        guard let self = self else { return }
//        let keywordRegisterViewController
//          = StoryboardScene.Start.startKeywordRegisterViewController.instantiate()
//        keywordRegisterViewController.reactor = KeywordRegisterViewReactor()
//        keywordRegisterViewController.push(at: self)
//      })
//      .disposed(by: disposeBag)
    // 알려주세요 버튼 눌렸는지에 대한 상태 바인딩
    reactor.state.map { $0.isInquiryButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let mailComposer = self.formMailComposeViewController()
        self.present(mailComposer, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
  /// UI 바인딩.
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
          InitialInfo.shared.university.onNext(university)
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

// MARK: - Private Method

private extension UniversitySelectionViewController {
  
  /// 메일 작성 뷰 컨트롤러 만들기.
  func formMailComposeViewController() -> UIViewController {
    let mailComposer = MFMailComposeViewController().then {
      $0.mailComposeDelegate = self
      $0.setToRecipients(["yoohan95@gmail.com"])
      $0.setSubject("[다연결] 우리 학교가 목록에 없어요.")
      $0.setMessageBody("\n\n\n\n\n\n피드백 감사합니다.", isHTML: false)
    }
    return mailComposer
  }
}
