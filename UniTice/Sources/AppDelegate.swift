//
//  AppDelegate.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 10/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  let gcmMessageIDKey = "gcm.message_id"
  
  let realmService: RealmServiceType = RealmService()
  
  let disposeBag = DisposeBag()
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 앱에서 파이어베이스 초기화
    FirebaseApp.configure()
    // 노티피케이션 델리게이트 설정
    UNUserNotificationCenter.current().delegate = self
    // 원격 알림 등록
    application.registerForRemoteNotifications()
    // 파이어베이스 등록 토큰 접근. 메세지 델리게이트 설정
    Messaging.messaging().delegate = self
    // 첫 화면 설정
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.tintColor = .main
    
    realmService.fetchUser()
      .observeOn(MainScheduler.instance)
      .ifEmpty(default: User())
      .subscribe(onNext: { [weak self] user in
        if !user.university.isEmpty {
          Global.shared.university.onNext(University(rawValue: user.university) ?? .kaist)
          UserDefaults.standard.set(true, forKey: "fold")
          let controller = StoryboardScene.Main.mainNavigationController.instantiate()
          (controller.topViewController as? MainContainerViewController)?.reactor
             = MainContainerViewReactor()
          self?.window?.rootViewController = controller
          self?.window?.makeKeyAndVisible()
        } else {
          self?.addShortcut(to: application)
          let controller = StoryboardScene.Start.startNavigationController.instantiate()
          (controller.topViewController as? UniversitySelectionViewController)?.reactor
            = UniversitySelectionViewReactor()
          self?.window?.rootViewController = controller
          self?.window?.makeKeyAndVisible()
        }
      })
      .disposed(by: disposeBag)
    return true
  }
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    // 언제 호출되는지 모르겠다
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }
    print(userInfo)
  }
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // 언제 호출되는지 모르겠다
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }
    print(userInfo)
    completionHandler(.newData)
  }
  
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Unable to register for remote notifications: \(error.localizedDescription)")
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNs token retrieved: \(deviceToken)")
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      let hasNotificationGranted = settings.authorizationStatus == .authorized ? true : false
      NotificationCenter.default.post(name: .willEnterForeground,
                                      object: nil,
                                      userInfo: ["hasNotificationGranted": hasNotificationGranted])
    }
  }
}

// MARK: - User Notification

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // 앱이 포어그라운드에 있을 때 알림이 오면 호출됨. 화면에는 배너가 뜨지 않으나 데이터는 옴
    let userInfo = notification.request.content.userInfo
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }
    print(userInfo)
    completionHandler([])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    // 사용자가 푸시 알림에 반응한 직후 호출됨. 백그라운드에서 배너를 터치하는 등
    // 사용자가 반응했을 시에 게시물 저장은 가능할 것 같아 보임
    let userInfo = response.notification.request.content.userInfo
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }
    print(userInfo)
    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    // 이 토큰으로 푸시 알림 디바이스 식별. 여기에 서버에 저장하는 코드 작성하기
    // 또는 FCMToken으로 보내진 노티피케이션을 받아서 다른 곳에서 서버 업로드 코드를 작성해도 됨
    // 토큰이 유효하지 않거나 갱신되었을 때도 호출됨
    print("Firebase registration token: \(fcmToken)")
    let dataDict: [String: String] = ["token": fcmToken]
    NotificationCenter.default
      .post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Received data message: \(remoteMessage.appData)")
  }
}

// MARK: - App Shortcut

extension AppDelegate {
  
  func application(_ application: UIApplication,
                   performActionFor shortcutItem: UIApplicationShortcutItem,
                   completionHandler: @escaping (Bool) -> Void) {
    if shortcutItem.type == "Bookmark" {
      presentBookmark()
    }
  }
  
  private func presentBookmark() {
    if window?.rootViewController == nil {
      let mainViewcontroller = StoryboardScene.Main.mainNavigationController.instantiate()
      window?.rootViewController = mainViewcontroller
      window?.makeKeyAndVisible()
    } else {
      let bookmarkViewController = StoryboardScene.Main.bookmarkViewController.instantiate()
      (window?.rootViewController as? UINavigationController)?
        .pushViewController(bookmarkViewController, animated: true)
    }
  }
  
  private func addShortcut(to application: UIApplication) {
    let bookmarkShortcut
      = UIMutableApplicationShortcutItem(type: "Bookmark",
                                         localizedTitle: "북마크",
                                         localizedSubtitle: nil,
                                         icon: UIApplicationShortcutIcon(type: .bookmark),
                                         userInfo: nil)
    application.shortcutItems = [bookmarkShortcut]
  }
}
