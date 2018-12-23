//
//  PostCell.swift
//  UniTice
//
//  Created by Presto on 22/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SkeletonView

class PostCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "postCell")
        isSkeletonable = true
        textLabel?.isSkeletonable = true
        detailTextLabel?.isSkeletonable = true
        textLabel?.text = "asdfasdfsadfasdfasdfasdfsadfsadf"
        detailTextLabel?.text = "asdfasdfasdf"
        textLabel?.showAnimatedGradientSkeleton()
        detailTextLabel?.showAnimatedGradientSkeleton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
