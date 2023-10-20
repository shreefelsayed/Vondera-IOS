//
//  OrderListExt.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI
import Foundation

extension Array where Element == OrderProductObject {
    
    func getTotalQuantity() -> Int {
        var total = 0
        
        for prod in self {
            total += prod.quantity
        }
        
        return total
    }
}


// MARK : Extenstions on lists
extension Array where Element == Order {
    func getValidOrders() -> [Order] {
        return self.filter { $0.statue != "Deleted"}
    }
    
    func getFinalProductList() -> [OrderProductObject] {
        var finalList:[OrderProductObject] = []
        
        for order in self {
            for orderProductObject in order.listProducts! {
                if let index = finalList.firstIndex(where: { $0.isEqual(orderProductObject) }) {
                                finalList[index].quantity += orderProductObject.quantity
                            } else {
                                finalList.append(orderProductObject)
                            }
            }
        }
        
        finalList.sort { 
            $0.quantity > $1.quantity
        }
        
        return finalList
    }
    
    private func isItemAlreadyInList(_ listFinal: [OrderProductObject], _ orderProductObject: OrderProductObject) -> OrderProductObject? {
        
        for listItem in listFinal {
            if listItem.productId == orderProductObject.productId && listItem.hashVaraients == orderProductObject.hashVaraients {
                return listItem
            }
        }
        return nil
    }

    
    func totalNetProfit() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += order.netProfit
        }
        
        return amout
    }
    
    func totalCommission() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += (order.commission ?? 0)
        }
        
        return amout
    }
    
    func totalCost() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += Int(order.buyingPrice)
        }
        
        return amout
    }
    
    func totalSales() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += Int(order.getSellingPrice())
        }
        
        return amout
    }
    
    func totalCODAfterCourier() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += Int(order.CODAfterCourier)
        }
        
        return amout
    }
    
    func productsCount() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += order.productsCount
        }
        
        return amout
    }
    
    func shippingFees() -> Int {
        let valid = self.getValidOrders()
        var amout = 0
        
        valid.forEach { order in
            amout += (order.courierShippingFees ?? 0)
        }
        
        return amout
    }
    
    func getSuccessPercentage() -> Int {
        let delv = self.getByStatue(statue: "Delivered").count
        let returns = self.getByStatue(statue: "Failed").count
        
        if (delv + returns) == 0 {
            return 0
        }
        
        return Int(Double(delv) / Double(delv + returns) * 100)
    }
    
    func getByStatue(statue:String) -> [Order] {
        return self.filter { $0.statue == statue}
    }
}
