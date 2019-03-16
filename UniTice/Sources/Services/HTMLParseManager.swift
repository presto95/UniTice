//
//  Kanna.swift
//  UniTice
//
//  Created by Presto on 13/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna
import RxSwift

/// HTML 파싱 매니저 프로토콜.
protocol HTMLParseManagerType: class {
  
  /// 해당 `url`의 HTML 도큐먼트 요청.
  func request(_ url: URL, encoding: String.Encoding) -> Observable<HTMLDocument>
}

/// HTML 파싱 매니저.
final class HTMLParseManager: HTMLParseManagerType {
  
  /// HTMLParseManager Singleton Object.
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
