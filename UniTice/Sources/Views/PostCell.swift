//
//  PostCell.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

/// The post cell.
final class PostCell: UITableViewCell, View {
  
  // MARK: Typealias
  
  typealias Reactor = PostCellReactor
  
  private enum Font {
    
    static let text = UIFont.systemFont(ofSize: 15, weight: .semibold)
    
    static let detailText = UIFont.systemFont(ofSize: 13, weight: .light)
  }
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: "postCell")
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func bind(reactor: Reactor) {
    textLabel?.attributedText
      = reactor.currentState.sectionData.title.highlightKeywords(reactor.currentState.keywords)
    detailTextLabel?.text = reactor.currentState.sectionData.date
  }
  
  private func setup() {
    textLabel?.numberOfLines = 0
    textLabel?.font = Font.text
    detailTextLabel?.font = Font.detailText
  }
}
