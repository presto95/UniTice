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
  
  func registerUserNotification() -> Observable<Bool>
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
  
  func registerUserNotification() -> Observable<Bool> {
    return Observable.create { observer in
      let options: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current()
        .requestAuthorization(options: options) { isGranted, error in
          if let error = error {
            errorLog(error.localizedDescription)
            observer.onCompleted()
            return
          }
          observer.onNext(isGranted)
          if !UserDefaults.standard.bool(forKey: "showsAlertIfPermissionDenied") {
            let content = UNMutableNotificationContent().then {
              $0.title = ""
              $0.body = "오늘은 무슨 공지사항이 새로 올라왔을까요? 확인해 보세요."
            }
            var dateComponents = DateComponents()
            dateComponents.hour = 0
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                        repeats: true)
            let request = UNNotificationRequest(identifier: "localNotification",
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
              if let error = error {
                errorLog(error.localizedDescription)
                return
              }
            }
            UserDefaults.standard.set(true, forKey: "showsAlertIfPermissionDenied")
          }
          observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
