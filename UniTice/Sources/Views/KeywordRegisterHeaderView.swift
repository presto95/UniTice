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

/// The keyword register header view.
final class KeywordRegisterHeaderView: UIView, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = KeywordRegisterHeaderViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet weak var keywordTextField: UITextField!
  
  func bind(reactor: Reactor) { }
}
