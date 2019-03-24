//
//  MainNoticeHeaderView.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

/// The main notice header view.
final class MainNoticeHeaderView: UIView, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = MainNoticeHeaderViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()

  /// The fold button.
  @IBOutlet private weak var foldButton: UIButton!
  
  // MARK: Method
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
  
  /// Sets up the initial settings.
  private func setup() {
    foldButton.do {
      $0.setTitle(nil, for: [])
      $0.imageView?.contentMode = .scaleAspectFit
    }
  }
}

// MARK: - Reactor Binding

private extension MainNoticeHeaderView {
  
  func bindAction(_ reactor: Reactor) {
    foldButton.rx.tap
      .map { Reactor.Action.toggleFolding }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isUpperPostFolded }
      .distinctUntilChanged()
      .map { $0 ? Asset.arrowDown.image : Asset.arrowUp.image }
      .bind(to: foldButton.rx.image())
      .disposed(by: disposeBag)
  }
}
