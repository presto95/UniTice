//
//  UTButtonType.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import UIKit

enum UTButtonType: Int {
  
  case next
  
  case back
  
  var title: String {
    switch self {
    case .next:
      return "확인"
    case .back:
      return "뒤로"
    }
  }
  
  var color: UIColor {
    switch self {
    case .next:
      return .main
    case .back:
      return .red
    }
  }
}
