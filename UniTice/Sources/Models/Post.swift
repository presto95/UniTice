//
//  Post.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 11/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import Then

/// 게시물 형태를 정의한 구조체.
struct Post {
  
  /// 게시물 번호.
  ///
  /// `Int`로 캐스팅되지 않으면 0을 저장하며, 이는 상단 고정 게시물인 것으로 취급한다.
  let number: Int
  
  /// 게시물 제목.
  let title: String
  
  /// 게시물 게시 날짜.
  ///
  /// 날짜와 다른 정보(캠퍼스 등)가 함께 저장될 수 있다.
  let date: String
  
  /// 게시물 링크.
  let link: String
}

// MARK: - CustomStringConvertiebl 준수

extension Post: CustomStringConvertible {
  
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
