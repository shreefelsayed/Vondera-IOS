//
//  OrderManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/06/2023.
//

import Foundation
import FirebaseFirestore
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

    
    
    func outForDelivery(list: inout [Order], courier:Courier) async {
        for var order in list {
            order = await outForDelivery(order: &order, courier: courier)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
    }
    
    func outForDelivery(order: inout Order, courier:Courier) async -> Order {
        if !(order.requireDelivery ?? true) { return order }
        
        let ordersDao = OrdersDao(storeId: order.storeId!)
        let fees = getFees(order.gov, courier.listPrices)
        
        var hash:[String:Any] = [:]
        hash["statue"] = "Out For Delivery"
        hash["courierId"] = courier.id
        hash["courierName"] = courier.name
        hash["courierShippingFees"] = fees
        hash["dateShipping"] = Timestamp(date: Date())
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        await addComment(order: &order, msg: "", code: OUT_FOR_DELV_CODE)
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
        let ordersDao = OrdersDao(storeId: order.storeId!)
        var hashMap = [String: Any]()
        hashMap["statue"] = "Pending"
        hashMap["courierId"] = ""
        hashMap["courierName"] = ""
        hashMap["courierShippingFees"] = 0
        hashMap["dateShipping"] = nil
        hashMap["dateDelivered"] = nil
        hashMap["dateAssembled"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hashMap)
        await addComment(order: &order, msg: "", code: RESET_ORDER)
        order.statue = "Pending"
        order.courierId = ""
        order.courierName = ""
        order.courierShippingFees = 0
        order.dateShipping = nil
        order.dateAssembled = nil
        order.dateDelivered = nil
        
        return order
    }

    func orderDelete(list: inout [Order]) async {
        for var order in list {
            order = await orderDelete(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
    }

    func orderDelete(order: inout Order) async -> Order {
        if !order.canDeleteOrder(accountType: "Worker") { return order }
        
        let ordersDao = OrdersDao(storeId: order.storeId!)
        var hash:[String:Any] = [:]
        hash["statue"] = "Deleted"
        hash["dateDelivered"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        await addComment(order: &order, msg: "", code: DELETED_CODE)
        order.statue = "Deleted"
        order.dateDelivered = nil
        
        return order
    }
    
    func orderDelivered(list: inout [Order]) async {
        for var order in list {
            order = await orderDelivered(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
    }
    
    func orderDelivered(order: inout Order) async -> Order {
        let ordersDao = OrdersDao(storeId: order.storeId!)
        var hash:[String:Any] = [:]
        hash["statue"] = "Delivered"
        hash["dateDelivered"] = Timestamp(date: Date())
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        await addComment(order: &order, msg: "", code: DONE_CODE)
        order.statue = "Delivered"
        order.dateDelivered = Timestamp(date: Date())
        return order
    }
    
    func assambleOrder(list: inout [Order]) async {
        for var order in list {
            order = await assambleOrder(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
            }
        }
    }
    
    func assambleOrder(order: inout Order) async -> Order {
        let ordersDao = OrdersDao(storeId: order.storeId!)
        var hash:[String:Any] = [:]
        hash["statue"] = "Assembled"
        hash["dateAssembled"] = Timestamp(date: Date())
        hash["courierId"] = ""
        hash["dateDelivered"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        await addComment(order: &order, msg: "", code: ASSEMBLED_CODE)
        order.statue = "Assembled"
        order.dateAssembled = Timestamp(date: Date())
        order.courierId = ""
        order.dateDelivered = nil
        return order
    }
    
    func confirmOrder(list: inout [Order]) async {
        for var order in list {
            order = await confirmOrder(order: &order)
            
            // Update the order in the list
            if let index = list.firstIndex(where: { $0 == order }) {
                list[index] = order
                print("Order updated")
            }
        }
    }
    
    func confirmOrder(order: inout Order) async -> Order {
        let ordersDao = OrdersDao(storeId: order.storeId!)
        var hash:[String:Any] = [:]
        hash["statue"] = "Confirmed"
        hash["dateConfirmed"] = Timestamp(date: Date())
        hash["courierId"] = ""
        hash["dateDelivered"] = nil
        
        try! await ordersDao.update(id: order.id, hashMap: hash)
        await addComment(order: &order, msg: "", code: CONFIRM_CODE)
        order.statue = "Confirmed"
        order.dateConfirm = Timestamp(date: Date())
        order.courierId = ""
        order.dateDelivered = nil
        
        return order
    }
    
    // This is used to add an order to the project
    func addOrder(order: inout Order) async {
        let ordersDao = OrdersDao(storeId: order.storeId!)
        
        do {
            // Add Commession if exists
            await checkCommission(order:&order)
            
            // Add the order
            try await ordersDao.add(order: order)
            
            // Clear the cart
            await CartManager().clearCart()
            
            // update the local store values
            await onNewOrderAdded(storeId: order.storeId!)
            
            // Copy data to clipboard
            CopyingData().copyToClipboard(order.toString())
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func checkCommission(order: inout Order) async {
        let myUser = await LocalInfo().getLocalUser()
        if myUser!.accountType == "Marketing" && (myUser?.percentage ?? 0 ) > 0 {
            order.commission = (Int(myUser!.percentage! / 100) * order.netProfit)
        } else {
            order.percPaid = true
        }
    }
    
    func onNewOrderAdded(storeId:String) async {
        var myUser = await LocalInfo().getLocalUser()
        if myUser?.storeId == storeId {
            myUser?.store?.ordersCount! += 1
            myUser?.store?.subscribedPlan?.currentOrders += 1
            if (myUser?.store?.subscribedPlan?.currentOrders ?? 0) >= (myUser?.store?.subscribedPlan?.maxOrders ?? 0) {
                myUser?.store?.subscribedPlan?.expired = true
            }
            
            _ = await LocalInfo().saveUser(user: myUser!)
        }
    }
    
    func addComment(order: inout Order, msg:String, code:Int) async {
        let myUser = await LocalInfo().getLocalUser()
        let ordersDao = OrdersDao(storeId: order.storeId!)
        let update = Updates(text: msg, uId: myUser?.id ?? "", code: code)
        order.listUpdates?.append(update)
        try! await ordersDao.addUpdate(id: order.id, update: update)
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
