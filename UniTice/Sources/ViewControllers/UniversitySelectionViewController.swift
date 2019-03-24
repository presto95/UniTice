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

/// The University selection view controller.
final class UniversitySelectionViewController: UIViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = UniversitySelectionViewReactor
  
  // MARK: Property
  
  var disposeBag = DisposeBag()
  
  /// The picker view representing the list of uniersities.
  @IBOutlet private weak var pickerView: UIPickerView!
  
  /// The notice button for mailing.
  @IBOutlet private weak var inquiryButton: UIButton!
  
  /// The confirm button.
  @IBOutlet private weak var confirmButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: Reactor) {
    bindUI()
    bindAction(reactor)
    bindState(reactor)
  }
  
  /// Sets up the initial settings.
  private func setup() {
    confirmButton.type = .next
  }
}

// MARK: - Reactor Binding

private extension UniversitySelectionViewController {
  
  func bindAction(_ reactor: Reactor) {
    pickerView.rx.modelSelected(University.self)
      .map { $0.first }
      .filterNil()
      .map { Reactor.Action.selectUniversity($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    inquiryButton.rx.tap
      .map { Reactor.Action.inquiry }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isConfirmButtonTapped }
      .distinctUntilChangedTrue()
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let keywordRegisterViewController
          = StoryboardScene.Start.startKeywordRegisterViewController.instantiate().then {
            $0.reactor = KeywordRegisterViewReactor()
        }
        keywordRegisterViewController.push(at: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isInquiryButtonTapped }
      .distinctUntilChangedTrue()
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let mailComposer = self.makeMailComposeViewController()
        self.present(mailComposer, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Conforming MFMailComposeViewControllerDelegate

extension UniversitySelectionViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}

// MARK: - Private Method

private extension UniversitySelectionViewController {
  
  func bindUI() {
    Observable.just(University.allCases)
      .bind(to: pickerView.rx.itemTitles) { _, element in element.rawValue }
      .disposed(by: disposeBag)
  }
  
  /// Creates the mail compose view controller.
  func makeMailComposeViewController() -> UIViewController {
    return MFMailComposeViewController().then {
      $0.mailComposeDelegate = self
      $0.setToRecipients(["yoohan95@gmail.com"])
      $0.setSubject("[다연결] 우리 학교가 목록에 없어요.")
      $0.setMessageBody("\n\n\n\n\n\n피드백 감사합니다.", isHTML: false)
    }
  }
}
