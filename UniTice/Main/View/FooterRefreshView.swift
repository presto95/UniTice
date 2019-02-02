//
//  FooterRefreshView.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

final class FooterRefreshView: UIView {
  
  var isLoading: Bool {
    return activityIndicatorView.isAnimating
  }
  
  private lazy var activityIndicatorView: UIActivityIndicatorView! = {
    let indicator = UIActivityIndicatorView(style: .gray)
    indicator.color = .main
    indicator.hidesWhenStopped = true
    addSubview(indicator)
    return indicator
  }()
  
  private lazy var textLabel: UILabel! = {
    let label = UILabel()
    label.text = "👆위로 스와이프하여 더 많은 게시물 가져오기✨"
    label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    label.sizeToFit()
    label.isHidden = true
    addSubview(label)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    activityIndicatorView.center = center
    textLabel.center = center
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func activate() {
    DispatchQueue.main.async {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      self.activityIndicatorView.startAnimating()
      self.textLabel.isHidden = true
    }
  }
  
  func deactivate() {
    DispatchQueue.main.async {
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      self.activityIndicatorView.stopAnimating()
      self.textLabel.isHidden = false
    }
  }
}
