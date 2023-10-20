//
//  Statics.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUICharts
import FirebaseFirestore
import Foundation
import LineChartView

struct StoreStatics: Identifiable, Codable {
    var id = ""
    var income = 0
    var orders = 0
    var delivered = 0
    var failed = 0
    var date:Timestamp = Timestamp(date: Date())
}

extension Array where Element == StoreStatics {
    
    func getLinearChartIncome() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
                items.append(LineChartData(Double(item.income), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
                
            
        }
        return items
    }
    
    func getTotalIncome() -> Int {
        var total = 0
        for item in self {
            total += item.income
        }
        
        return total
    }
    
    func getLinearChartOrder() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.orders), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
                
            
        }
        return items
    }
    
    func getTotalOrders() -> Int {
        var total = 0
        for item in self {
            total += item.orders
        }
        
        return total
    }
    

}
