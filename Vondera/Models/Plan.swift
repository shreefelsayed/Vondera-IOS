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
    var planDesc: String = ""
    var planType: String = "Paid"
    var planDuration: String = "Monthly"
    var planNameAr: String = ""
    var planDescAr: String = ""

    var maxOrders: Int = 0
    var customMessage: Bool = false
    var accessApis: Bool = false
    var clients: Bool = false
    var employeesCount: Int = 0
    var accessStockReport: Bool = false
    var accessExpenses: Bool = false
}
