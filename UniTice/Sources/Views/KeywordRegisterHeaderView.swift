//
//  HeaderView.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class KeywordRegisterHeaderView: UIView, StoryboardView {
  
  typealias Reactor = KeywordRegisterHeaderViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet private weak var keywordTextField: UITextField!
  
  @IBOutlet private weak var addButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
  
  private func setup() {
    addButton.imageView?.contentMode = .scaleAspectFit
  }
}

// MARK: - Reactor Binding

private extension KeywordRegisterHeaderView {
  
  func bindAction(_ reactor: Reactor) {
    keywordTextField.rx.controlEvent(.editingDidEndOnExit)
      .map { Reactor.Action.returnTextField }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    keywordTextField.rx.tapGesture()
      .map { _ in Reactor.Action.tapTextField }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    keywordTextField.rx.text
      .map { Reactor.Action.input($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    addButton.rx.tap
      .map { Reactor.Action.add }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isTextFieldSelected }
      .distinctUntilChanged()
      .filter { !$0 }
      .subscribe(onNext: { [weak self] _ in
        self?.keywordTextField.resignFirstResponder()
      })
      .disposed(by: disposeBag)
    
    reactor.state.map { $0.currentKeyword }
      .filter { $0 == nil }
      .bind(to: keywordTextField.rx.text)
      .disposed(by: disposeBag)
  }
}
