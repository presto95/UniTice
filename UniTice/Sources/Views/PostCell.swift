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

final class PostCell: UITableViewCell, View {
  
  private enum Font {
    
    static let text = UIFont.systemFont(ofSize: 15, weight: .semibold)
    
    static let detailText = UIFont.systemFont(ofSize: 13, weight: .light)
  }
  
  var disposeBag: DisposeBag = DisposeBag()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: "postCell")
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func bind(reactor: PostCellReactor) {
    textLabel?.text = reactor.currentState.title
    detailTextLabel?.text = reactor.currentState.date
  }
  
  private func setup() {
    textLabel?.numberOfLines = 0
    textLabel?.font = Font.text
    detailTextLabel?.font = Font.detailText
  }
}
