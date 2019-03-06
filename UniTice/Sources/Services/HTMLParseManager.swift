//
//  Kanna.swift
//  UniTice
//
//  Created by Presto on 13/01/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Kanna
import RxSwift

protocol HTMLParseManagerType: class {
  
  func request(_ url: URL, encoding: String.Encoding) -> Observable<HTMLDocument>
}

final class HTMLParseManager: HTMLParseManagerType {
  
  static let shared = HTMLParseManager()
  
  func request(_ url: URL, encoding: String.Encoding = .utf8) -> Observable<HTMLDocument> {
    return Observable.create { observer in
      do {
        let document = try HTML(url: url, encoding: encoding)
        observer.onNext(document)
        observer.onCompleted()
      } catch {
        observer.onError(error)
      }
      return Disposables.create()
    }
  }
}
