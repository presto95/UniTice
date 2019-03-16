//
//  FooterRefreshView.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class FooterRefreshView: UIView, View {
  
  typealias Reactor = FooterRefreshViewReactor
  
  var disposeBag: DisposeBag = DisposeBag()
  
  private let activityIndicator = UIActivityIndicatorView().then {
    $0.color = .main
    $0.hidesWhenStopped = true
  }
  
  private let textLabel = UILabel().then {
    $0.text = "👆위로 스와이프하여 더 많은 게시물 가져오기✨"
    $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    $0.sizeToFit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
  
  private func setup() {
    activityIndicator.center = center
    textLabel.center = center
    addSubview(activityIndicator)
    addSubview(textLabel)
  }
}

// MARK: - Reactor Binding

private extension FooterRefreshView {
  
  func bindAction(_ reactor: Reactor) {
    
  }
  
  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] isLoading in
        self?.reloadSubviews(isLoading)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension FooterRefreshView {
  
  func reloadSubviews(_ isLoading: Bool) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
    textLabel.isHighlighted = isLoading
    if isLoading {
      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()
    }
  }
}
