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
    var income:Int? = 0
    var orders:Int? = 0
    var delivered:Int? = 0
    var failed:Int? = 0
    var sales:Int? = 0
    var site:Int? = 0
    var site_orders:Int? = 0
    var added_to_cart:Int? = 0
    var site_products_view:Int? = 0
    var date:Timestamp = Timestamp(date: Date())
}

extension Array where Element == StoreStatics {
    func getProductsViewsData() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.site_products_view ?? 0), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
        }
        return items
    }
    
    func getTotalProductsView() -> Int {
        var total = 0
        for item in self {
            total += item.site_products_view ?? 0
        }
        
        return total
    }
    
    func getAddedToCartData() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.added_to_cart ?? 0), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
        }
        return items
    }
    
    func getTotalAddedToCart() -> Int {
        var total = 0
        for item in self {
            total += item.added_to_cart ?? 0
        }
        
        return total
    }
    
    func getVisitorsData() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.site ?? 0), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
        }
        return items
    }
    
    func getTotalVisitors() -> Int {
        var total = 0
        for item in self {
            total += item.site ?? 0
        }
        
        return total
    }
    
    func getLinechartSales() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.sales ?? 0), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
        }
        return items
    }
    
    func getTotalSales() -> Int {
        var total = 0
        for item in self {
            total += item.sales ?? 0
        }
        
        return total
    }
    
    func getLinearChartIncome() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.income ?? 0), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
                
            
        }
        return items
    }
    
    func getTotalIncome() -> Int {
        var total = 0
        for item in self {
            total += item.income ?? 0
        }
        
        return total
    }
    
    func getLinearChartOrder() -> [LineChartData] {
        var items:[LineChartData] = []
        for item in self {
            items.append(LineChartData(Double(item.orders ?? 0), timestamp: item.date.toDate(), label: item.date.toDate().formatted(date: .abbreviated, time: .shortened)))
                
            
        }
        return items
    }
    
    func getTotalOrders() -> Int {
        var total = 0
        for item in self {
            total += item.orders ?? 0
        }
        
        return total
    }
    

}
