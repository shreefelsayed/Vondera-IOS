//
//  Plan.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Plan: Codable, Identifiable {
    @DocumentID var id: String?
    var price: Int = 0
    var planName: String = ""
    var planNameAr: String = ""
    
    var planDesc: String = ""
    var planDescAr: String = ""
    
    var planType: String = "Paid"
    var planDuration: String = "Monthly"
    
    var maxOrders: Int = 0
    var employeesCount: Int = 0
    
    var customMessage: Bool? = false
    var accessApis: Bool? = false
    var clients: Bool? = false
    var accessStockReport: Bool? = false
    var accessExpanses: Bool? = false
    var website:Bool? = false
    
}

extension Plan {
    var features: [Feature] {
        var features: [Feature] = []
        features.append(Feature(name: "\(employeesCount) Employees", available: (self.employeesCount > 0)))
        features.append(Feature(name: "\(maxOrders) Monthly Orders", available: (self.maxOrders > 0)))
        
        //DEFAULT
        features.append(Feature(name: "Unlimited Products", available: true))
        features.append(Feature(name: "Sales Reports", available: true))
        features.append(Feature(name: "Order Receipts", available: true))
        features.append(Feature(name: "Clients Data", available: clients ?? false))
        features.append(Feature(name: "Access Stock Report", available: accessStockReport ?? false))
        features.append(Feature(name: "Access Expenses", available: accessExpanses ?? false))
        features.append(Feature(name: "ECommerce Website", available: website ?? false))

        features.append(Feature(name: "Custom Message", available: customMessage ?? false))
        features.append(Feature(name: "Access APIs", available: accessApis ?? false))
        return features
    }
}

struct Feature: Hashable {
    var name: String
    var available: Bool
}
