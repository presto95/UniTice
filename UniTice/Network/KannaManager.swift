//
//  Kanna.swift
//  UniTice
//
//  Created by Presto on 13/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna

final class KannaManager {
  
  static let shared = KannaManager()
  
  func request(_ url: URL,
               encoding: String.Encoding = .utf8,
               strategyHandler strategy: @escaping ((HTMLDocument?, Error?) -> Void)) {
    DispatchQueue.global(qos: .background).async {
      do {
        let doc = try HTML(url: url, encoding: encoding)
        strategy(doc, nil)
      } catch {
        strategy(nil, error)
      }
    }
  }
}
