//
//  UTButtonType.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import UIKit

/// UniTice 버튼 타입.
enum UTButtonType: Int {
  
  /// 다음으로, 확인 등 긍정적 액션.
  case next
  
  /// 뒤로, 취소 등 부정적 액션.
  case back
  
  /// 타입에 따른 타이틀.
  var title: String {
    switch self {
    case .next:
      return "확인"
    case .back:
      return "뒤로"
    }
  }
  
  /// 타입에 따른 색상.
  var color: UIColor {
    switch self {
    case .next:
      return .main
    case .back:
      return .red
    }
  }
}
