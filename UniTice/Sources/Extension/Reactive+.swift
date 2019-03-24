//
//  Reactive+.swift
//  UniTice
//
//  Created by Presto on 24/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

extension Reactive where Base: KeywordRegisterHeaderView {
  
  var keywordTextFieldDidReturn: ControlEvent<String> {
    let source = base.keywordTextField.rx
      .controlEvent(.editingDidEndOnExit)
      .withLatestFrom(base.keywordTextField.rx.text.orEmpty)
    return ControlEvent(events: source)
  }
}

extension Reactive where Base: MainNoticeHeaderView {
  
  var isUpperPostFolded: ControlEvent<Bool> {
    let source = base.reactor!.state.map { $0.isUpperPostFolded }
    return ControlEvent(events: source)
  }
}
