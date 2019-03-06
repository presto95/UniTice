//
//  UTButton.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import UIKit

/// UniTice 버튼 커스텀 클래스.
@IBDesignable
final class UTButton: UIButton {
  
  /// UniTice 버튼 타입.
  var type: UTButtonType {
    get {
      return _type
    }
    set {
      _type = newValue
      setState(newValue)
    }
  }
  
  private var _type: UTButtonType = .next
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  convenience init(type: UTButtonType) {
    self.init(frame: .zero)
    setup()
  }
  
  private func setup() {
    layer.cornerRadius = bounds.height / 2
    layer.borderWidth = 1
    titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
  }
  
  private func setState(_ type: UTButtonType) {
    setTitle(type.title, for: [])
    setTitleColor(type.color, for: [])
    layer.borderColor = type.color.cgColor
  }
}
