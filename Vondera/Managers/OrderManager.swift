//
//  OrderManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/06/2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI
class OrderManager {
    let CONFIRM_CODE = 10
    let NEW_CODE = 12
    let DELETED_CODE = 13
    let OUT_FOR_DELV_CODE = 15
    let CHANGE_SHIPPING_PRICE = 21
    let RESET_ORDER = 25

    let DONE_CODE = 16
    let ASSEMBLED_CODE = 20
    let FAILED_CODE = 17
    let PART_CODE = 18
    let EDIT_CODE = 19
    
    func outForDelivery(list: inout [Order], courier:Courier) async -> [Order] {
        for var order in list {
            order = await outForDelivery(order: &order, courier: courier)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
        
        return list
    }
    
    func canAddToCourier(order:Order, courierId:String) -> (confirmed: Bool, msg:LocalizedStringKey) {
        if !(order.requireDelivery ?? true) {
            return (confirmed : false, msg: "Order doesn't need delivery")
        }
        
        if order.courierId == courierId && order.statue == "Out For Delivery" {
            return (confirmed : false, msg: "Order already with courier")
        }
        
        if order.statue == "Deleted" {
            return (confirmed : false, msg: "Order is deleted")
        }
        
        return (confirmed : true, msg: "")
    }
    
    func outForDelivery(order: inout Order, courier:Courier) async -> Order {
        guard canAddToCourier(order: order, courierId: courier.id).confirmed else {
            return order
        }
        
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        
        let ordersDao = OrdersDao(storeId: storeId)
        let fees = getFees(order.gov, courier.listPrices)
        
        var hash:[String:Any] = [:]
        hash["statue"] = "Out For Delivery"
        hash["courierId"] = courier.id
        hash["storeId"] = storeId
        hash["courierName"] = courier.name
        hash["courierShippingFees"] = fees
        hash["dateShipping"] = Timestamp(date: Date())
        hash["courierConnected"] = !(courier.courierHandler ?? "").isBlank
        hash["courierInfo"] = [:]
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        order = await addComment(order: &order, msg: "", code: OUT_FOR_DELV_CODE)
        order.statue = "Out For Delivery"
        order.courierId = courier.id
        order.courierName = courier.name
        order.courierShippingFees = fees
        order.dateShipping = Timestamp(date: Date())
        
        return order
    }
    
    func getFees(_ gov:String, _ prices:[CourierPrice]) -> Int {
        for state in prices {
            if state.govName == gov {
                return state.price
            }
        }
        
        return 0
    }
    
    func orderFailed(order: inout Order) async -> Order {
        return order
    }
    
    func resetOrder(order: inout Order) async -> Order {
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        let ordersDao = OrdersDao(storeId: storeId)
        var hashMap = [String: Any]()
        hashMap["statue"] = "Pending"
        hashMap["storeId"] = storeId
        hashMap["courierId"] = ""
        hashMap["courierName"] = ""
        hashMap["courierShippingFees"] = 0
        hashMap["dateShipping"] = nil
        hashMap["dateDelivered"] = nil
        hashMap["dateAssembled"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hashMap)
        
        order = await addComment(order: &order, msg: "", code: RESET_ORDER)
        order.statue = "Pending"
        order.courierId = ""
        order.courierName = ""
        order.courierShippingFees = 0
        order.dateShipping = nil
        order.dateAssembled = nil
        order.dateDelivered = nil
        return order
    }

    func orderDelete(list: inout [Order]) async -> [Order]{
        for var order in list {
            order = await orderDelete(order: &order).result
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
        
        return list
    }

    func orderDelete(order: inout Order) async -> (result : Order, success: Bool) {
        guard let myUser = UserInformation.shared.getUser() else {
            return (order, false)
        }
        
        if !order.canDeleteOrder(accountType: myUser.accountType) {
            return (order, false)
        }
        
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return (order, false)
        }
                
        let ordersDao = OrdersDao(storeId: storeId)
        var hash:[String:Any] = [:]
        hash["statue"] = "Deleted"
        hash["storeId"] = storeId
        hash["dateDelivered"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        order = await addComment(order: &order, msg: "", code: DELETED_CODE)
        order.statue = "Deleted"
        order.dateDelivered = nil
        
        AnalyticsManager.shared.deleteOrder()
        return (order, true)
    }
    
    func orderDelivered(list: inout [Order]) async -> [Order]{
        for var order in list {
            
            order = await orderDelivered(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
        
        return list
    }
    
    
    func orderDelivered(order: inout Order) async -> Order {
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        
        let ordersDao = OrdersDao(storeId: storeId)
        var hash:[String:Any] = [:]
        hash["statue"] = "Delivered"
        hash["storeId"] = storeId
        hash["dateDelivered"] = Timestamp(date: Date())
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        order = await addComment(order: &order, msg: "", code: DONE_CODE)
        order.statue = "Delivered"
        order.dateDelivered = Timestamp(date: Date())
        return order
    }
    
    func assambleOrder(list: inout [Order]) async -> [Order] {
        for var order in list {
            order = await assambleOrder(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
        
        return list
    }
    
    func assambleOrder(order: inout Order) async -> Order {
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        let ordersDao = OrdersDao(storeId: storeId)
        
        var hash:[String:Any] = [:]
        hash["statue"] = "Assembled"
        hash["dateAssembled"] = Timestamp(date: Date())
        hash["courierId"] = ""
        hash["storeId"] = storeId
        hash["dateDelivered"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        order = await addComment(order: &order, msg: "", code: ASSEMBLED_CODE)
        order.statue = "Assembled"
        order.dateAssembled = Timestamp(date: Date())
        order.courierId = ""
        order.dateDelivered = nil
        return order
    }
    
    func confirmOrder(list: inout [Order]) async -> [Order] {
        for var order in list {
            order = await confirmOrder(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
        
        return list
    }
    
    func confirmOrder(order: inout Order) async -> Order {
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        let ordersDao = OrdersDao(storeId: storeId)
        
        var hash:[String:Any] = [:]
        hash["statue"] = "Confirmed"
        hash["dateConfirmed"] = Timestamp(date: Date())
        hash["courierId"] = ""
        hash["dateDelivered"] = nil
        hash["storeId"] = storeId
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        order = await addComment(order: &order, msg: "", code: CONFIRM_CODE)
        order.statue = "Confirmed"
        order.dateConfirm = Timestamp(date: Date())
        order.courierId = ""
        order.dateDelivered = nil
        
        return order
    }
    
    // This is used to add an order to the project
    func addOrder(order: inout Order) async -> Order {
        if let myUser = UserInformation.shared.user {
            let ordersDao = OrdersDao(storeId: myUser.storeId)
            do {
                order.storeId = myUser.storeId
                order.addBy = myUser.id
                order.owner = myUser.name
                order.listUpdates?.append(Updates(uId: myUser.id, code: 12))
                
                // Add Commession if exists
                await checkCommission(order:&order)
                
                // Add the order
                try await ordersDao.add(order: order)
                
                // Clear the cart
                CartManager().clearCart()
                
                // update the local store values
                await onNewOrderAdded(storeId: order.storeId!)
                
                // Copy data to clipboard
                CopyingData().copyToClipboard(order.toString())
                
                AnalyticsManager.shared.flyOrderAdded()
                return order
            } catch {
                print("\(error.localizedDescription)")
                return order
            }
        }
        
        return order
    }
    
    func checkCommission(order: inout Order) async {
        let myUser = UserInformation.shared.getUser()
        if myUser!.accountType == "Marketing" && (myUser?.percentage ?? 0 ) > 0 {
            order.commission = Double(Int(myUser!.percentage! / 100) * order.netProfit)
        } else {
            order.percPaid = true
        }
    }
    
    func onNewOrderAdded(storeId:String) async {
        if var myUser = UserInformation.shared.user {
            myUser.ordersCount! += 1
            myUser.store?.ordersCount! += 1
            myUser.store?.storePlanInfo?.planFeatures.currentOrders += 1
            myUser.store?.ordersCountObj?.Pending! += 1
            
            if (myUser.store?.storePlanInfo?.planFeatures.currentOrders ?? 0) >= (myUser.store?.storePlanInfo?.planFeatures.maxOrders ?? 0) {
                myUser.store?.storePlanInfo?.expired = true
            }
            
            UserInformation.shared.updateUser(myUser)
        }
    }
    
    func addComment(order: inout Order, msg:String, code:Int) async -> Order  {
        let myUser = UserInformation.shared.getUser()
        let ordersDao = OrdersDao(storeId: order.storeId!)
        
        let update = Updates(text: msg, uId: myUser?.id ?? "", code: code)
        order.listUpdates?.append(update)
        try! await ordersDao.addUpdate(id: order.id, update: update)
        return order
    }
    
    func listAttachments(orders: [Order]) -> [URL] {
        var list = [URL]()
        for order in orders {
            if let listAttachments = order.listAttachments {
                let attachmentsURLs = listAttachments.compactMap { URL(string: $0) }
                list.append(contentsOf: attachmentsURLs)
            }
        }
        return list
    }
}
