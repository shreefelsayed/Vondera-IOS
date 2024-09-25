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
    
    func outForDelivery(list: [Order], courier: Courier) async -> [Order] {
        var updatedList = [Order]()
        
        for order in list {
            let updatedOrder = await outForDelivery(order: order, courier: courier)
            updatedList.append(updatedOrder)
        }
        
        return updatedList
    }
    
    func canAddToCourier(order: Order, courierId: String) -> (confirmed: Bool, msg: LocalizedStringKey) {
        if !(order.requireDelivery ?? true) {
            return (false, "Order doesn't need delivery")
        }
        
        if order.courierId == courierId && order.statue == "Out For Delivery" {
            return (false, "Order already with courier")
        }
        
        if order.statue == "Deleted" {
            return (false, "Order is deleted")
        }
        
        return (true, "")
    }
    
    func outForDelivery(order: Order, courier: Courier) async -> Order {
        var order = order
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
        
        var hash: [String: Any] = [
            "statue": "Out For Delivery",
            "courierId": courier.id,
            "storeId": storeId,
            "courierName": courier.name,
            "courierShippingFees": fees,
            "dateShipping": Timestamp(date: Date()),
            "courierConnected": !(courier.courierHandler ?? "").isBlank,
            "courierInfo": [:]
        ]
        
        do {
            try await ordersDao.update(id: order.id, hashMap: hash)
            var updatedOrder = await addComment(order: order, msg: "", code: OUT_FOR_DELV_CODE)
            updatedOrder.statue = "Out For Delivery"
            updatedOrder.courierId = courier.id
            updatedOrder.courierName = courier.name
            updatedOrder.courierShippingFees = fees
            updatedOrder.dateShipping = Timestamp(date: Date())
            return updatedOrder
        } catch {
            print("Failed to update order: \(error.localizedDescription)")
            return order
        }
    }
    
    func getFees(_ gov: String, _ prices: [CourierPrice]) -> Double {
        return prices.first(where: { $0.govName == gov })?.price ?? 0.0
    }
    
    func orderFailed(order: Order) async -> Order {
        return order
    }
    
    func resetOrder(order: Order) async -> Order {
        var order = order
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        
        let ordersDao = OrdersDao(storeId: storeId)
        let hashMap: [String: Any?] = [
            "statue": "Pending",
            "storeId": storeId,
            "courierId": "",
            "courierName": "",
            "courierShippingFees": 0,
            "dateShipping": nil,
            "dateDelivered": nil,
            "dateAssembled": nil
        ]
        
        do {
            try await ordersDao.update(id: order.id, hashMap: hashMap)
            var updatedOrder = await addComment(order: order, msg: "", code: RESET_ORDER)
            updatedOrder.statue = "Pending"
            updatedOrder.courierId = ""
            updatedOrder.courierName = ""
            updatedOrder.courierShippingFees = 0
            updatedOrder.dateShipping = nil
            updatedOrder.dateAssembled = nil
            updatedOrder.dateDelivered = nil
            return updatedOrder
        } catch {
            print("Failed to reset order: \(error.localizedDescription)")
            return order
        }
    }
    
    func orderDelete(list: [Order]) async -> [Order] {
        var updatedList = [Order]()
        
        for order in list {
            let (updatedOrder, success) = await orderDelete(order: order)
            if success {
                updatedList.append(updatedOrder)
            }
        }
        
        return updatedList
    }
    
    func orderDelete(order: Order) async -> (result: Order, success: Bool) {
        var order = order
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
        let hash: [String: Any?] = [
            "statue": "Deleted",
            "storeId": storeId,
            "dateDelivered": nil
        ]
        
        do {
            try await ordersDao.update(id: order.id, hashMap: hash)
            var updatedOrder = await addComment(order: order, msg: "", code: DELETED_CODE)
            updatedOrder.statue = "Deleted"
            updatedOrder.dateDelivered = nil
            AnalyticsManager.shared.deleteOrder()
            return (updatedOrder, true)
        } catch {
            print("Failed to delete order: \(error.localizedDescription)")
            return (order, false)
        }
    }
    
    func orderDelivered(list: [Order]) async -> [Order] {
        var updatedList = [Order]()
        
        for order in list {
            let updatedOrder = await orderDelivered(order: order)
            updatedList.append(updatedOrder)
        }
        
        return updatedList
    }
    
    func orderDelivered(order: Order) async -> Order {
        var order = order
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        
        let ordersDao = OrdersDao(storeId: storeId)
        let hash: [String: Any] = [
            "statue": "Delivered",
            "storeId": storeId,
            "dateDelivered": Timestamp(date: Date())
        ]
        
        do {
            try await ordersDao.update(id: order.id, hashMap: hash)
            var updatedOrder = await addComment(order: order, msg: "", code: DONE_CODE)
            updatedOrder.statue = "Delivered"
            updatedOrder.dateDelivered = Timestamp(date: Date())
            return updatedOrder
        } catch {
            print("Failed to mark order as delivered: \(error.localizedDescription)")
            return order
        }
    }
    
    func assambleOrder(list: [Order]) async -> [Order] {
        var updatedList = [Order]()
        
        for order in list {
            let updatedOrder = await assambleOrder(order: order)
            updatedList.append(updatedOrder)
        }
        
        return updatedList
    }
    
    func assambleOrder(order: Order) async -> Order {
        var order = order
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        
        let ordersDao = OrdersDao(storeId: storeId)
        let hash: [String: Any?] = [
            "statue": "Assembled",
            "dateAssembled": Timestamp(date: Date()),
            "courierId": "",
            "storeId": storeId,
            "dateDelivered": nil
        ]
        
        do {
            try await ordersDao.update(id: order.id, hashMap: hash)
            var updatedOrder = await addComment(order: order, msg: "", code: ASSEMBLED_CODE)
            updatedOrder.statue = "Assembled"
            updatedOrder.dateAssembled = Timestamp(date: Date())
            updatedOrder.courierId = ""
            updatedOrder.dateDelivered = nil
            return updatedOrder
        } catch {
            print("Failed to assemble order: \(error.localizedDescription)")
            return order
        }
    }
    
    func confirmOrder(list: [Order]) async -> [Order] {
        var updatedList = [Order]()
        
        for order in list {
            let updatedOrder = await confirmOrder(order: order)
            updatedList.append(updatedOrder)
        }
        
        return updatedList
    }
    
    func confirmOrder(order: Order) async -> Order {
        var order = order
        if (order.storeId ?? "").isEmpty {
            order.storeId = UserInformation.shared.user?.storeId ?? ""
        }
        
        guard let storeId = order.storeId, !storeId.isBlank else {
            return order
        }
        
        let ordersDao = OrdersDao(storeId: storeId)
        let hash: [String: Any?] = [
            "statue": "Confirmed",
            "dateConfirmed": Timestamp(date: Date()),
            "courierId": "",
            "dateDelivered": nil,
            "storeId": storeId
        ]
        
        do {
            try await ordersDao.update(id: order.id, hashMap: hash)
            var updatedOrder = await addComment(order: order, msg: "", code: CONFIRM_CODE)
            updatedOrder.statue = "Confirmed"
            updatedOrder.dateConfirmed = Timestamp(date: Date())
            updatedOrder.dateDelivered = nil
            updatedOrder.courierId = ""
            return updatedOrder
        } catch {
            print("Failed to confirm order: \(error.localizedDescription)")
            return order
        }
    }
    // This is used to add an order to the project
        func addOrder(order: Order) async -> Order {
            guard let myUser = UserInformation.shared.user else {
                print("User information is missing.")
                return order
            }
            
            let ordersDao = OrdersDao(storeId: myUser.storeId)
            
            do {
                var mutableOrder = order
                mutableOrder.storeId = myUser.storeId
                mutableOrder.addBy = myUser.id
                mutableOrder.owner = myUser.name
                mutableOrder.listUpdates?.append(Updates(uId: myUser.id, code: 12))
                
                // Check and add commission if applicable
                await checkCommission(order: &mutableOrder)
                
                // Add the order
                try await ordersDao.add(order: mutableOrder)
                
                // Clear the cart
                CartManager().clearCart()
                
                // Update the local store values
                await onNewOrderAdded(storeId: mutableOrder.storeId!)
                
                // Copy data to clipboard
                CopyingData().copyToClipboard(mutableOrder.toString())
                
                // Log the event
                AnalyticsManager.shared.flyOrderAdded()
                
                return mutableOrder
            } catch {
                print("Failed to add order: \(error.localizedDescription)")
                return order
            }
        }
        
        func checkCommission(order: inout Order) async {
            guard let myUser = UserInformation.shared.getUser(),
                  let perc = myUser.percentage, perc > 0 else {
                order.percPaid = true
                return
            }
            
            order.commission = perc / 100 * order.netProfit
        }
        
        func onNewOrderAdded(storeId: String) async {
            guard var myUser = UserInformation.shared.user else {
                print("User information is missing.")
                return
            }
            
            myUser.ordersCount? += 1
            myUser.store?.ordersCount? += 1
            myUser.store?.storePlanInfo?.planFeatures.currentOrders += 1
            myUser.store?.ordersCountObj?.Pending? += 1
            
            if (myUser.store?.storePlanInfo?.planFeatures.currentOrders ?? 0) >=
               (myUser.store?.storePlanInfo?.planFeatures.maxOrders ?? 0) {
                myUser.store?.storePlanInfo?.expired = true
            }
            
            UserInformation.shared.updateUser(myUser)
        }
        
        func addComment(order: Order, msg: String, code: Int) async -> Order {
            guard let myUser = UserInformation.shared.getUser(), let storeId = order.storeId else {
                print("User information or store ID is missing.")
                return order
            }
            
            let ordersDao = OrdersDao(storeId: storeId)
            
            let update = Updates(text: msg, uId: myUser.id, code: code)
            
            var mutableOrder = order
            mutableOrder.listUpdates?.append(update)
            
            do {
                try await ordersDao.addUpdate(id: order.id, update: update)
                return mutableOrder
            } catch {
                print("Failed to add comment: \(error.localizedDescription)")
                return order
            }
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
