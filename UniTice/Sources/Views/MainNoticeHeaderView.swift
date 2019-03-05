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

final class MainNoticeHeaderView: UIView, StoryboardView {
  
  typealias Reactor = MainNoticeHeaderViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
//  var state: Bool = false {
//    didSet {
//      foldButton.setImage(state ? UIImage(named: "arrow_down") : UIImage(named: "arrow_up"),
//                          for: [])
//    }
//  }
  
  //var foldingHandler: (() -> Void)?
  
  @IBOutlet weak var foldButton: UIButton! {
    didSet {
//      foldButton.setTitle(nil, for: [])
//      foldButton.imageView?.contentMode = .scaleAspectFit
      //foldButton.addTarget(self, action: #selector(foldButtonDidTap(_:)), for: .touchUpInside)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
//  @objc private func foldButtonDidTap(_ sender: UIButton) {
//    foldingHandler?()
//  }
  
  private func setup() {
    foldButton.setTitle(nil, for: [])
    foldButton.imageView?.contentMode = .scaleAspectFit
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
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
    reactor.state.map { $0.isFolding }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isFolding in
        guard let self = self else { return }
        let image = isFolding ? UIImage(named: "arrow_down") : UIImage(named: "arrow_up")
        self.foldButton
          .setImage(image, for: [])
        // 상단 고정 게시물 펼치기 또는 숨기기 설정
      })
      .disposed(by: disposeBag)
  }
}
