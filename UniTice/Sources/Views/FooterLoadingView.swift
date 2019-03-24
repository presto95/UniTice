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

/// The footer loading view used in `MainContentTableViewController` and `SearchViewController`.
final class FooterLoadingView: UIView, View {
  
  // MARK: Typealias
  
  typealias Reactor = FooterLoadingViewReactor
  
  // MARK: Property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  /// The activity indicator appeared if it is in loading.
  private let activityIndicator = UIActivityIndicatorView().then {
    $0.color = .main
    $0.hidesWhenStopped = true
  }
  
  /// The label appeared if it is not in loading.
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

private extension FooterLoadingView {

  func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] isLoading in
        self?.reloadSubviews(loading: isLoading)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Method

private extension FooterLoadingView {
  
  /// Reloads subviews by `loading` status.
  ///
  /// - Parameter loading: The boolean value indicating whether the view is in loading.
  func reloadSubviews(loading isLoading: Bool) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
    if isLoading {
      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()
    }
    activityIndicator.isHidden = !isLoading
    textLabel.isHidden = isLoading
  }
}
