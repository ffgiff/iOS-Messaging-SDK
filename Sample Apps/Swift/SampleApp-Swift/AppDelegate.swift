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
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        // Register for push remote push notifications
        debugPrint("+didFinishLaunchingWithOptions push")
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
//        application.registerForRemoteNotifications()
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        LPMessaging.instance.setLoggingLevel(level: .TRACE)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint("+didRegisterForRemoteNotificationsWithDeviceToken push \(String(decoding: deviceToken, as: UTF8.self))")
        do {
            try LPMessaging.instance.initialize("83559791")
            LPMessaging.instance.registerPushNotifications(
                token: deviceToken,
                notificationDelegate: self,
//                authenticationParams: nil
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
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        debugPrint("+application(_:didReceiveRemoteNotification:fetchCompletionHandler)")
//        debugPrint("badge: \(userInfo["badge"]!)")
//        LPMessaging.instance.handlePush(userInfo)
//    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        debugPrint("+didFailToRegisterForRemoteNotificationsWithError push \(error)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint("+application(_:didReceive:withCompletionHandler)")
//        debugPrint("badge: \(response.notification.request.content.userInfo["badge"]!)")
//        let accountNumber = "83559791"
//        LPMessaging.instance.getPendingProactiveMessages(
//            LPMessaging.instance.getConversationBrandQuery(accountNumber),
//            authenticationParams: LPAuthenticationParams(
//                authenticationCode: "sub:test",
//                jwt: nil,
//                redirectURI: "https://liveperson.net",
//                issuerDisplayName: "firebase",
//                certPinningPublicKeys: nil,
//                authenticationType: .authenticated),
//            alternateBundleID: nil) { notifications in
//                debugPrint("notifications: \(notifications)")
//                LPMessaging.instance.handleTapForInAppNotifications(notifications: notifications, clearOthers: false)
//                let campaignInfo = LPCampaignInfo(
//                    campaignId: Int(response.notification.request.content.proActiveData!.leCampaignId!)!,
//                    engagementId: Int(response.notification.request.content.proActiveData!.leEngagementId!)!,
//                    contextId: nil, sessionId: nil, visitorId: nil)
//                let conversationQuery = LPMessaging.instance.getConversationBrandQuery(accountNumber, campaignInfo: campaignInfo)
////                let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, isViewOnly: false, welcomeMessage: LPWelcomeMessage(message: nil))
//                let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, isViewOnly: false, welcomeMessage: LPWelcomeMessage(message: response.notification.request.content.text))
//                LPMessaging.instance.showConversation(conversationViewParam)
//            } failure: { error in
//                debugPrint("error: \(error)")
//            }
        LPMessaging.instance.handlePush(response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("+application(_:willPresent:withCompletionHandler)")
//        debugPrint("badge: \(notification.request.content.userInfo["badge"]!)")
        LPMessaging.instance.handlePush(notification.request.content.userInfo)
        if (notification.request.content.userInfo["badge"] != nil) {
            completionHandler(.badge)
        } else {
            completionHandler(.badge)
        }
    }
}

//MARK: - LPMessagingSDKNotificationDelegate
/*
  For more information on `LPMessagingSDKNotificationDelegate` see:
      https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-customizing-toast-notifications.html
 */
extension AppDelegate: LPMessagingSDKNotificationDelegate {
    func LPMessagingSDKNotification(shouldShowPushNotification notification: LPNotification) -> Bool {
        debugPrint("+LPMessagingSDKNotification:shouldShowPushNotification")
        return true
    }
    
    func LPMessagingSDKNotification(didReceivePushNotification notification: LPNotification) {
        debugPrint("+LPMessagingSDKNotification:didReceivePushNotification")
    }
    
    func LPMessagingSDKNotification(notificationTapped notification: LPNotification) {
        debugPrint("+LPMessagingSDKNotification:notificationTapped")
        let accountNumber = "83559791"
        LPMessaging.instance.getPendingProactiveMessages(
            LPMessaging.instance.getConversationBrandQuery(accountNumber),
            authenticationParams: LPAuthenticationParams(
                authenticationCode: "sub:test",
                jwt: nil,
                redirectURI: "https://liveperson.net",
                issuerDisplayName: "firebase",
                certPinningPublicKeys: nil,
                authenticationType: .authenticated),
            alternateBundleID: nil) { notifications in
                debugPrint("notifications: \(notification)")
                LPMessaging.instance.handleTapForInAppNotifications(notifications: [notification], clearOthers: false)
                let campaignInfo = LPCampaignInfo(
                    campaignId: Int(notification.proActiveData!.leCampaignId!)!,
                    engagementId: Int(notification.proActiveData!.leEngagementId!)!,
                    contextId: nil, sessionId: nil, visitorId: nil)
                let conversationQuery = LPMessaging.instance.getConversationBrandQuery(accountNumber, campaignInfo: campaignInfo)
//                let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, isViewOnly: false, welcomeMessage: LPWelcomeMessage(message: nil))
                let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, isViewOnly: false, welcomeMessage: LPWelcomeMessage(message: notification.text))
                LPMessaging.instance.showConversation(conversationViewParam)
            } failure: { error in
                debugPrint("error: \(error)")
            }
    }
    
    // Example on how to implement a custom InApp Notification that supports Proactive and IVR Deflection
//    func LPMessagingSDKNotification(customLocalPushNotificationView notification: LPNotification) -> UIView {
//        debugPrint("+LPMessagingSDKNotification:customLocalPushNotificationView")
//        let view = Toast(frame: CGRect(x: 0,
//                                       y: 0,
//                                       width: UIScreen.main.bounds.width,
//                                       height: 110))
//        view.set(with: notification)
//        return view
//    }
}
