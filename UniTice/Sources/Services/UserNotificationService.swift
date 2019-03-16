//
//  UserNotificationService.swift
//  UniTice
//
//  Created by Presto on 16/03/2019.
//  Copyright © 2019 presto. All rights reserved.
//

import Foundation
import UserNotifications

import RxSwift

protocol UserNotificationServiceType: class {
  
  func requestUserNotificationIsAuthorized() -> Observable<Bool>
}

final class UserNotificationService: UserNotificationServiceType {
  
  static let shared = UserNotificationService()

  func requestUserNotificationIsAuthorized() -> Observable<Bool> {
    return Observable.create { observer in
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
          observer.onNext(true)
        } else {
          observer.onNext(false)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
