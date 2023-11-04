//
//  Plan.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct Plan: Codable, Identifiable {
    var id: String = ""
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
        features.append(Feature(id: 0,name: "\(employeesCount) Team members", available: (self.employeesCount > 0)))
        features.append(Feature(id: 1,name: "\(maxOrders) Orders / month", available: (self.maxOrders > 0)))
        
        //DEFAULT
        features.append(Feature(id: 2,name: "Vonder's ecommerce website", available: website ?? false))
        features.append(Feature(id: 3,name: "Shoppers data", available: clients ?? false))
        
        features.append(Feature(id: 4,name: "Warehouse & Stock Report", available: accessStockReport ?? false))
        features.append(Feature(id: 5,name: "Expanses records", available: accessExpanses ?? false))

        features.append(Feature(id: 6,name: "Customize receipt", available: customMessage ?? false))
        features.append(Feature(id: 7,name: "Access our api and end-points and webhooks", available: accessApis ?? false))
        return features
    }
}

struct Feature: Identifiable {
    var id: Int
    var name: LocalizedStringKey
    var available: Bool
}
