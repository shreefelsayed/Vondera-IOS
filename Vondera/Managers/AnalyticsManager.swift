//
//  AnalyticsManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/10/2023.
//

import Foundation
import FirebaseAnalytics
import FirebaseAnalyticsSwift


final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    func push(_ name:String, _ params:[String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func deleteStore() {
        push("store_deleted")
    }
    
    func openedPlansInfo() {
        push("plans_screen")
    }
    
    func loggedOut() {
        push("logged_out")
    }
    
    func signUp(method:String = "email") {
        push(AnalyticsEventSignUp, [AnalyticsParameterMethod : method])
    }
    
    func appOpened() {
        push(AnalyticsEventAppOpen)
    }
    
    func loggedIn(method:String) {
        push(AnalyticsEventLogin, [AnalyticsParameterMethod : method])
    }
    
    func flyOrderAdded() {
        push("new_order")
    }
    
    func deleteOrder() {
        push("delete_order")
    }
    
    func paymentAttemp() {
        push("apple_pay_attemp")
    }
    
    func setUsersParams() {
        if let user = UserInformation.shared.user {
            Analytics.setUserID(user.id)
            Analytics.setUserProperty(user.store?.name, forName: "store_name")
            Analytics.setUserProperty(user.accountType, forName: "type")
            Analytics.setUserProperty(user.store?.storePlanInfo?.name ?? "", forName: "plan")
        }
    }
    
}
