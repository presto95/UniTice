//
//  ChangeSchoolViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class UniversityChangeViewController: UIViewController, StoryboardView {
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet private weak var pickerView: UIPickerView!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: UniversityChangeViewReactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
  
  private func setup() {
    title = "학교 변경"
    confirmButton.type = .next
  }
}

// MARK: - Reactor Binding

private extension UniversityChangeViewController {
  
  func bindAction(_ reactor: UniversityChangeViewReactor) {
    confirmButton.rx.tap
      .map { Reactor.Action.touchUpConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    pickerView.rx.itemSelected
      .map { row, _ in
        return Reactor.Action.changeUniversity(University.allCases[row])
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: UniversityChangeViewReactor) {
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    Observable
      .just(University.allCases)
      .bind(to: pickerView.rx.itemTitles) { _, element in
        return element.rawValue
      }
      .disposed(by: disposeBag)
  }
}
