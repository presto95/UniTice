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
  
  private func setup() {
    foldButton.setTitle(nil, for: [])
    foldButton.imageView?.contentMode = .scaleAspectFit
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
      .subscribe(onNext: { [weak self] isFolded in
        let image = isFolded ? Asset.arrowDown.image : Asset.arrowUp.image
        self?.foldButton.setImage(image, for: [])
      })
      .disposed(by: disposeBag)
  }
}
