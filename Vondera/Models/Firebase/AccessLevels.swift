//
//  AccessLevels.swift
//  Vondera
//
//  Created by Shreif El Sayed on 12/07/2024.
//

import Foundation

import Foundation

struct AccessLevels: Codable {
    var orders: AccessPermission = AccessPermission()
    var expenses: ExpensePermissions = ExpensePermissions()
    var statistics: StatisticPermissions = StatisticPermissions()
    var customersData: CustomerPermissions = CustomerPermissions()
    var accessCouriers: CourierPermissions = CourierPermissions()
    var warehouse: WarehousePermissions = WarehousePermissions()
    var products: AccessPermission = AccessPermission()
    var categories: AccessPermission = AccessPermission()
    var teamMembers: TeamMemberPermissions = TeamMemberPermissions()
    var vPay: VPayPermissions = VPayPermissions()
    var complaints: ComplaintPermissions = ComplaintPermissions()
    
    var subscription: Bool = false
    var websiteCustomization: Bool = false
    var storeSettings: Bool = false

    func getAccountantDefault() -> AccessLevels {
        var levels = AccessLevels()
        levels.orders = AccessPermission(read: true, write: false, update: false, delete: false)
        levels.expenses = ExpensePermissions(read: true, add: true, remove: true, export: true)
        levels.statistics = StatisticPermissions(read: true, export: true)
        levels.customersData = CustomerPermissions(read: true, export: true)
        levels.warehouse = WarehousePermissions(read: true, add: false, export: true)
        levels.teamMembers = TeamMemberPermissions(read: true, add: false, update: false, delete: false)
        levels.vPay = VPayPermissions(read: true, payouts: true)
        return levels
    }
    
    func getAdminDefault() -> AccessLevels {
        var levels = AccessLevels()
        levels.orders = AccessPermission(read: true, write: true, update: true, delete: true)
        levels.expenses = ExpensePermissions(read: true, add: true, remove: true, export: true)
        levels.statistics = StatisticPermissions(read: true, export: true)
        levels.customersData = CustomerPermissions(read: true, export: true)
        levels.accessCouriers = CourierPermissions(add: true, assign: true, remove: true)
        levels.warehouse = WarehousePermissions(read: true, add: true, export: true)
        levels.products = AccessPermission(read: true, write: true, update: true, delete: true)
        levels.categories = AccessPermission(read: true, write: true, update: true, delete: true)
        levels.teamMembers = TeamMemberPermissions(read: true, add: true, update: true, delete: true)
        levels.vPay = VPayPermissions(read: true, payouts: false)
        levels.complaints = ComplaintPermissions(read: true, add: true, update: true)
        levels.websiteCustomization = true
        levels.storeSettings = true
        return levels
    }
    
    func getMarketingDefault() -> AccessLevels {
        var levels = AccessLevels()
        levels.orders = AccessPermission(read: true, write: true, update: true, delete: false)
        levels.customersData = CustomerPermissions(read: true, export: false)
        levels.products = AccessPermission(read: true, write: false, update: false, delete: false)
        levels.categories = AccessPermission(read: true, write: false, update: false, delete: false)
        levels.complaints = ComplaintPermissions(read: true, add: true, update: true)
        return levels
    }
    
    func getEmployeeDefault() -> AccessLevels {
        var levels = AccessLevels()
        levels.orders = AccessPermission(read: true, write: true, update: true, delete: true)
        levels.customersData = CustomerPermissions(read: true, export: false)
        levels.products = AccessPermission(read: true, write: false, update: false, delete: false)
        levels.categories = AccessPermission(read: true, write: false, update: false, delete: false)
        levels.complaints = ComplaintPermissions(read: true, add: true, update: true)
        levels.accessCouriers = CourierPermissions(add: false, assign: true, remove: false)
        levels.teamMembers = TeamMemberPermissions(read: true, add: false, update: false, delete: false)
        levels.warehouse = WarehousePermissions(read: true, add: false, export: false)
        return levels
    }
    
    
    struct AccessPermission: Codable {
        var read: Bool = false
        var write: Bool = false
        var update: Bool = false
        var delete: Bool = false
    }
    
    struct ExpensePermissions: Codable {
        var read: Bool = false
        var add: Bool = false
        var remove: Bool = false
        var export: Bool = false
    }
    
    struct StatisticPermissions: Codable {
        var read: Bool = false
        var export: Bool = false
    }
    
    struct CustomerPermissions: Codable {
        var read: Bool = false
        var export: Bool = false
    }
    
    struct CourierPermissions: Codable {
        var add: Bool = false
        var assign: Bool = false
        var remove: Bool = false
    }
    
    struct WarehousePermissions: Codable {
        var read: Bool = false
        var add: Bool = false
        var export: Bool = false
    }
    
    struct TeamMemberPermissions: Codable {
        var read: Bool = false
        var add: Bool = false
        var update: Bool = false
        var delete: Bool = false
    }
    
    struct VPayPermissions: Codable {
        var read: Bool = false
        var payouts: Bool = false
    }
    
    struct ComplaintPermissions: Codable {
        var read: Bool = false
        var add: Bool = false
        var update: Bool = false
    }
}
