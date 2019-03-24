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

/// The keyword cell.
@IBDesignable
final class KeywordCell: UITableViewCell, StoryboardView {
  
  // MARK: Typealias
  
  typealias Reactor = KeywordCellReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet private weak var keywordLabel: UILabel!
  
  // MARK: Method
  
  override func awakeFromNib() {
    super.awakeFromNib()
    configure()
  }
  
  func bind(reactor: Reactor) {
    keywordLabel.text = reactor.currentState
  }
  
  private func configure() {
    keywordLabel.layer.do {
      $0.cornerRadius = $0.bounds.height / 2
      $0.borderColor = UIColor.main.cgColor
      $0.borderWidth = 1
    }
  }
}
