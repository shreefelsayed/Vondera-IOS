import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    func registerForPushNotifications() async {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        // For iOS 10 data message (sent via FCM)
        Messaging.messaging().delegate = self
        
        await UIApplication.shared.registerForRemoteNotifications()
        await updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() async {
        if let token = Messaging.messaging().fcmToken {
            try! await UsersDao().update(id: userID, hash: ["device_token": token])
            print("Token should change \(token)")
        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) async {
        await updateFirestorePushTokenIfNeeded()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      let userInfo = notification.request.content.userInfo

      Messaging.messaging().appDidReceiveMessage(userInfo)

      // Change this to your preferred presentation option
      completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo

      Messaging.messaging().appDidReceiveMessage(userInfo)

      completionHandler()
    }

    func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      Messaging.messaging().appDidReceiveMessage(userInfo)
      completionHandler(.noData)
    }

}
