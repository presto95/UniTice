//
//  KeywordCell.swift
//  UniTice
//
//  Created by Presto on 20/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

@IBDesignable
final class KeywordCell: UITableViewCell, StoryboardView {
  
  typealias Reactor = KeywordCellReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet private weak var keywordLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  func bind(reactor: Reactor) {
    keywordLabel.text = reactor.currentState
  }
  
  private func setup() {
    keywordLabel.layer.cornerRadius = keywordLabel.bounds.height / 2
    keywordLabel.layer.borderColor = UIColor.main.cgColor
    keywordLabel.layer.borderWidth = 1
  }
}
