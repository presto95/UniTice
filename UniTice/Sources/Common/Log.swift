//
//  Log.swift
//  UniTice
//
//  Created by Presto on 28/02/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import UIKit

enum LogLevel: String {
  case debug = "👻"
  case info = "💡"
  case warning = "🚨"
  case error = "❌"
}

struct Log {
  /// 일반 로그 찍을 때 사용하기.
  static func debug(_ message: Any,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    #if DEBUG
    logger(level: .debug, message: message, file: file, function: function, line: line)
    #endif
  }
  
  /// info 로그 찍을 때 사용하기.
  static func info(_ message: Any,
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line) {
    logger(level: .info, message: message, file: file, function: function, line: line)
  }
  
  /// warning 로그 찍을 때 사용하기.
  static func warning(_ message: Any,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    logger(level: .warning, message: message, file: file, function: function, line: line)
  }
  
  /// 에러 로그 찍을 때 사용하기.
  static func error(_ message: Any,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    logger(level: .error, message: message, file: file, function: function, line: line)
  }
  
  static func logger(level: LogLevel, message: Any, file: String, function: String, line: Int) {
    let fileName = file.split(separator: "/").last ?? ""
    let functionName = function.split(separator: "(").first ?? ""
    print("\(level.rawValue) [\(fileName)] \(functionName)(\(line)): \(message)")
  }
}

