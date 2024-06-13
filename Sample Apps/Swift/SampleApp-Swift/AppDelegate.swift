//
//  AppDelegate.swift
//  SampleApp-Swift
//
//  Created by Nimrod Shai on 2/23/16.
//  Copyright © 2016 LivePerson. All rights reserved.
//

import UIKit
import LPMessagingSDK
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        // Register for push remote push notifications
        debugPrint("+didFinishLaunchingWithOptions push")
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint("+didRegisterForRemoteNotificationsWithDeviceToken push \(String(decoding: deviceToken, as: UTF8.self))")
        do {
            try LPMessaging.instance.initialize("83559791")
            LPMessaging.instance.registerPushNotifications(
                token: deviceToken,
                notificationDelegate: self,
                authenticationParams: LPAuthenticationParams(
                    authenticationCode: "sub:test",
                    jwt: nil,
                    issuerDisplayName: "firebase",
                    certPinningPublicKeys: nil
                )
            )
        } catch let error as NSError {
            print("initialize error: \(error)")
            LPMessaging.instance.registerPushNotifications(token: deviceToken, notificationDelegate: self)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("+application(_:didReceiveRemoteNotification:fetchCompletionHandler)")
        debugPrint("badge: \(userInfo["badge"]!)")
        LPMessaging.instance.handlePush(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        debugPrint("+didFailToRegisterForRemoteNotificationsWithError push \(error)")
    }
}

//MARK: - LPMessagingSDKNotificationDelegate
/*
  For more information on `LPMessagingSDKNotificationDelegate` see:
      https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-customizing-toast-notifications.html
 */
extension AppDelegate: LPMessagingSDKNotificationDelegate {
    func LPMessagingSDKNotification(shouldShowPushNotification notification: LPNotification) -> Bool {
        return true
    }
    
    func LPMessagingSDKNotification(didReceivePushNotification notification: LPNotification) {
        debugPrint("+LPMessagingSDKNotification:didReceivePushNotification")
    }
    
    func LPMessagingSDKNotification(notificationTapped notification: LPNotification) {
        debugPrint("+LPMessagingSDKNotification:notificationTapped")
    }
    
    // Example on how to implement a custom InApp Notification that supports Proactive and IVR Deflection
//    func LPMessagingSDKNotification(customLocalPushNotificationView notification: LPNotification) -> UIView {
//        let view = Toast(frame: CGRect(x: 0,
//                                       y: 0,
//                                       width: UIScreen.main.bounds.width,
//                                       height: 110))
//        view.set(with: notification)
//        return view
//    }
}
