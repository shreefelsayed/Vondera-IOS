import UIKit
import UserNotifications

import FirebaseCore
import FirebaseMessaging
import FirebaseAuth
import FirebaseFirestore
import Siren

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window?.makeKeyAndVisible()
        
        // FCM Notifications
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        // UPdate checker
        let siren = Siren.shared
        siren.rulesManager = RulesManager(majorUpdateRules: .critical, minorUpdateRules: .annoying, patchUpdateRules: .default, revisionUpdateRules: .relaxed)
        siren.wail()
        return true
    }
    
    
    // MARK : When we recieve a new notification this triggers
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let _ = Auth.auth().currentUser {
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            Messaging.messaging().appDidReceiveMessage(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    // --> Mark when a FCM token updates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let deviceToken:[String: String] = ["device_token": fcmToken ?? ""]
        print("FCM Token \(fcmToken)")
        if let user = UserInformation.shared.user {
            Task {
                try? await UsersDao().update(id: user.id, hash: deviceToken)
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        
        // --> Here we get the notification from userInfo
        guard let objectId = userInfo["objectId"] as! String?, let notificationType = userInfo["type"] as! String? else {
            print("Couldn't find prams")
            return
        }
        
        
        guard let view = NotificationModelMethods.getDestination(type: notificationType, objectId: objectId) else {
            print("Not Clickable")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // <- here!!
            print("Notification Clicked")
            DynamicNavigation.shared.navigate(to: view)
         }
        
        
        completionHandler()
    }
}
