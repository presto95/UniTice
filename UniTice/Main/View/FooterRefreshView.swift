//
//  FooterRefreshView.swift
//  UniTice
//
//  Created by Presto on 27/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class FooterRefreshView: UIView {

    var isLoading: Bool {
        return activityIndicatorView.isAnimating
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView! = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.color = .purple
        indicator.hidesWhenStopped =  true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityIndicatorView)
        activityIndicatorView.center = center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activate() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func deactivate() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicatorView.stopAnimating()
        }
    }
}
