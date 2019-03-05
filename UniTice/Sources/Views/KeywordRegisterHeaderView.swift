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
  
  var disposeBag: DisposeBag = DisposeBag()
  
  var addButtonDidTapHandler: ((String) -> Void)?
  
  @IBOutlet private weak var keywordTextField: UITextField! {
    didSet {
      keywordTextField.delegate = self
    }
  }
  
  @IBOutlet private weak var addButton: UIButton! {
    didSet {
      addButton.imageView?.contentMode = .scaleAspectFit
      addButton.addTarget(self, action: #selector(addButtonDidTap(_:)), for: .touchUpInside)
    }
  }
  
  func bind(reactor: KeywordRegisterHeaderViewReactor) {
    
  }
  
  @objc private func addButtonDidTap(_ sender: UIButton) {
    if let text = keywordTextField.text {
      guard !text.isEmpty else { return }
      addButtonDidTapHandler?(text.replacingOccurrences(of: " ", with: ""))
      keywordTextField.text = nil
    }
  }
}

extension KeywordRegisterHeaderView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
