//
//  Post.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 11/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Then

struct Post: CustomStringConvertible {
  
  let number: Int
  
  let title: String
  
  let date: String
  
  let link: String
  
  var description: String {
    return """
    -----
    글번호 : \(number)
    제목 : \(title)
    날짜 : \(date)
    링크 : \(link)
    -----
    """
  }
}

extension Post: Then { }
