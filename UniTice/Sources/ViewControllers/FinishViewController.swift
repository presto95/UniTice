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

/// The finish view controller.
final class FinishViewController: UIViewController, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = FinishViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  /// The university label.
  @IBOutlet private weak var universityLabel: UILabel!
  
  /// The keyword label.
  @IBOutlet private weak var keywordLabel: UILabel!
  
  /// The confirm button.
  @IBOutlet private weak var confirmButton: UTButton!
  
  /// The back button.
  @IBOutlet private weak var backButton: UTButton!
  
  // MARK: Method
  
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
    backButton.type = .back
  }
}

// MARK: - Reactor Binding

private extension FinishViewController {
  
  func bindAction(_ reactor: Reactor) {
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    backButton.rx.tap
      .map { Reactor.Action.back }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isConfirmButtonTapped }
      .distinctUntilChangedTrue()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let controller = StoryboardScene.Main.mainNavigationController.instantiate()
        controller.modalTransitionStyle = .flipHorizontal
        let topViewController = controller.topViewController as? MainContainerViewController
        topViewController?.reactor = MainContainerViewReactor()
        self.present(controller, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBackButtonTapped }
      .distinctUntilChangedTrue()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    let sharedInfo = InitialInfo.shared
    sharedInfo.university
      .take(1)
      .map { $0.rawValue }
      .bind(to: universityLabel.rx.text)
      .disposed(by: disposeBag)
    sharedInfo.keywords
      .take(1)
      .flatMap { Observable.from($0) }
      .reduce("") { "\($0) | \($1)" }
      .map { "\($0) |"}
      .bind(to: keywordLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
