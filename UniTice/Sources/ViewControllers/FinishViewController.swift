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
  
  @IBOutlet private weak var universityLabel: UILabel!
  
  @IBOutlet private weak var keywordLabel: UILabel!
  
  @IBOutlet private weak var confirmButton: UTButton!
  
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
      .distinctUntilChanged()
      .filter { $0 }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let mainViewController = StoryboardScene.Main.mainNavigationController.instantiate().then {
          let mainContainerViewController = $0.topViewController as? MainContainerViewController
          mainContainerViewController?.reactor = MainContainerViewReactor()
          $0.modalTransitionStyle = .flipHorizontal
        }
        self.present(mainViewController, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBackButtonTapped }
      .distinctUntilChanged()
      .filter { $0 }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUI() {
    let sharedInfo = InitialInfo.shared
    sharedInfo.university
      .map { $0.rawValue }
      .bind(to: universityLabel.rx.text)
      .disposed(by: disposeBag)
    sharedInfo.keywords
      .reduce("") { "\($0), \($1)" }
      .map { $0.components(separatedBy: ",") }
      .skip(1)
      .flatMap { Observable.from($0) }
      .bind(to: keywordLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
