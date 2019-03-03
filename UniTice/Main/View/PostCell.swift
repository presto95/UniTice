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
  
  var disposeBag: DisposeBag = DisposeBag()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: "postCell")
//    textLabel?.numberOfLines = 0
//    textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//    detailTextLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
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
    textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    detailTextLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)

  }
}
