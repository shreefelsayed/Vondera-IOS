//
//  OrderListExt.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import SwiftUI
import Foundation

extension Array where Element == OrderProductObject {
    func getTotalCost() -> Int {
        var total = 0
        for prod in self {
            total += Int(prod.quantity * Int(prod.price))
        }
        
        return total
    }
    
    func getTotalQuantity() -> Int {
        var total = 0
        
        for prod in self {
            total += prod.quantity
        }
        
        return total
    }
}

extension Array where Element == [String:[String]] {
    func getTitles() -> [String] {
        var titles = [String]()
        for item in self {
            if let firstKey = item.keys.first {
                titles.append(firstKey)
            }
        }
        
        return titles
    }
    
    func getOptions() -> [[String]] {
        var options = [[String]]()
        for item in self {
            if let firstKey = item.keys.first, let arrayValue = item[firstKey] {
                options.append(arrayValue)
            }
        }

        
        return options
    }
    
    func getOptions(_ index:Int) -> [String] {
        var options = [String]()
        let item = self[index]
        if let firstKey = item.keys.first, let arrayValue = item[firstKey] {
            options = arrayValue
        }
        
        return options
    }
}

// MARK : Extenstions on lists
extension Array where Element == Order {
    func getProductsCount() -> Int {
        let items = getValidOrders()
        var total = 0
        for item in items {
            if item.statue != "Failed" && !(item.part ?? false) {
                total += (item.quantity)
            }
        }
        return total
    }
    
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
    
    func getSellingCommission() -> Int {
        let items = getValidOrders()
        var total = 0
        
        for item in items {
            total += item.commission ?? 0
        }
        
        return total
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
    
    func getFinishedOrders() -> [Order] {
        return self.filter { $0.statue == "Delivered" || $0.statue == "Failed" }
    }
}
