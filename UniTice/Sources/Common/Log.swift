//
//  Log.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import UIKit

/// 일반 로그 찍을 때 사용하기.
func debugLog(_ message: Any,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
  #if DEBUG
  let fileName = file.split(separator: "/").last ?? ""
  let functionName = function.split(separator: "(").first ?? ""
  print("👻 [\(fileName)] \(functionName)(\(line)): \(message)")
  #endif
}

/// 에러 로그 찍을 때 사용하기.
func errorLog(_ message: Any,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
  let fileName = file.split(separator: "/").last ?? ""
  let functionName = function.split(separator: "(").first ?? ""
  print("❌ [\(fileName)] \(functionName)(\(line)): \(message)")
}
