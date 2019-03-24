//
//  Kanna.swift
//  UniTice
//
//  Created by Presto on 13/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna
import RxSwift

/// The `protocol` for html parse manager.
protocol HTMLParseManagerType: class {
  
  /// Requests the html document of the `url` by specific `encoding`.
  ///
  /// - Parameters:
  ///   - url:      The specific url that parsed.
  ///   - encoding: The specific string value encoding strategy.
  ///
  /// - Returns: The observable that emits `HTMLDocument`.
  func request(_ url: URL, encoding: String.Encoding) -> Observable<HTMLDocument>
}

/// The html parse manager.
final class HTMLParseManager: HTMLParseManagerType {
  
  /// The singleton object of `HTMLParseManager`.
  static let shared = HTMLParseManager()
  
  func request(_ url: URL, encoding: String.Encoding = .utf8) -> Observable<HTMLDocument> {
    return Observable.create { observer in
      DispatchQueue.global(qos: .utility).async {
        do {
          let document = try HTML(url: url, encoding: encoding)
          observer.onNext(document)
          observer.onCompleted()
        } catch {
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
}
