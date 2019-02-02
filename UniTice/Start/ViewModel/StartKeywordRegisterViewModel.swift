//
//  StartKeywordRegisterViewModel.swift
//  UniTice
//
//  Created by Presto on 13/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import RxSwift

struct StartKeywordRegisterViewModel {
  
  var keywords: Variable<[String]> = Variable([]) {
    didSet {
      InitialInfo.shared.keywords = keywords.value
    }
  }
}
