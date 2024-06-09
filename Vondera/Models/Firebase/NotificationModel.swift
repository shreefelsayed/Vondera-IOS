//
//  NotificationModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/10/2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct NotificationModel: Codable, Identifiable, Equatable {
    var id = ""
    var read = false
    var title = ""
    var body = ""
    var date:Timestamp = Timestamp(date: Date())
    var type = ""
    var objectId = ""
    
    init(id: String = "", read: Bool = false, title: String = "", body: String = "", date: Timestamp, type: String = "", objectId: String = "") {
        self.id = id
        self.read = read
        self.title = title
        self.body = body
        self.date = date
        self.type = type
        self.objectId = objectId
    }
    
    init() {
        
    }
    
    static func ==(lhs: NotificationModel, rhs: NotificationModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getDestination() -> AnyView? {
        return NotificationModelMethods.getDestination(type: type, objectId: objectId)
    }
    
    func getImage() -> ImageResource {
            switch type {
            case "announce":
                return .btnAnnounce
            case "warehouse":
                return .btnWarehouse
            case "order":
                return .btnOrders
            case "deletedOrder":
                return .btnDelete
            case "payout":
                return .btnVpay
            case "vpay":
                return .btnVpay
            case "newComplaint":
                return .btnComplaints
            case "plan":
                return .btnWarning
            case "website":
                return .btnWebsite
            case "reports":
                return .btnReports
            case "review":
                return .btnReview
            default:
                return .btnNotification
            }
        }
}

class NotificationModelMethods {
    class func getDestination(type:String, objectId:String) -> AnyView? {
        switch type {
        case "warehouse":
            return AnyView(WarehouseView(storeId: UserInformation.shared.user?.storeId ?? ""))
        case "order":
            return AnyView(OrderDetailLoading(id: objectId))
        case "deletedOrder":
            return AnyView(OrderDetailLoading(id: objectId))
        case "review":
            return AnyView(ProductLoadingScreen(id: objectId))
        case "payout":
            return AnyView(VPayScreen(selectedTab: 2))
        case "vpay":
            return AnyView(VPayScreen(selectedTab: 1))
        case "plan":
            return AnyView(SubscribtionsView())
        case "reports":
            return AnyView(StoreReport())
        default:
            return nil
        }
    }
}
