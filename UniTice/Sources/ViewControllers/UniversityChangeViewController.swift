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

/// The university change view controller.
final class UniversityChangeViewController: UIViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = UniversityChangeViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet private weak var pickerView: UIPickerView!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  // MARK: Method
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: Reactor) {
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
  
  func bindAction(_ reactor: Reactor) {
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    pickerView.rx.itemSelected
      .map { row, _ in
        let university = University.allCases[row]
        return Reactor.Action.changeUniversity(university)
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension UniversityChangeViewController {
  
  func bindUI() {
    Observable
      .just(University.allCases)
      .bind(to: pickerView.rx.itemTitles) { _, element in element.rawValue }
      .disposed(by: disposeBag)
  }
}
