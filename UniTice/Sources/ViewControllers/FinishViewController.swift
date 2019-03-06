//
//  StartFinishViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import RxViewController

/// 초기 설정 완료 뷰 컨트롤러.
final class FinishViewController: UIViewController, StoryboardView {
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet weak var universityLabel: UILabel!
  
  @IBOutlet weak var keywordLabel: UILabel!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  @IBOutlet private weak var backButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: FinishViewReactor) {
    bindAction(reactor)
    bindState(reactor)
    bindUI()
  }
  
  private func setup() {
    InitialInfo.shared.university
      .map { $0.rawValue }
      .bind(to: universityLabel.rx.text)
      .disposed(by: disposeBag)
    confirmButton.type = .next
    backButton.type = .back
  }
}

// MARK: - Reactor Binding

private extension FinishViewController {
  
  func bindAction(_ reactor: FinishViewReactor) {
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    backButton.rx.tap
      .map { Reactor.Action.back }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: FinishViewReactor) {
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let mainViewController = StoryboardScene.Main.mainNavigationController.instantiate().then {
          $0.modalTransitionStyle = .flipHorizontal
        }
        mainViewController.present(to: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBackButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    InitialInfo.shared.keywords
      .reduce("") { "\($0), \($1)" }
      .map { $0.components(separatedBy: ",") }
      .skip(1)
      .flatMap { Observable.from($0) }
      .bind(to: keywordLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
