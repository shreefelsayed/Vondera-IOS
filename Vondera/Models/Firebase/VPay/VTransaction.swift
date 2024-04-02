//
//  VTransaction.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/12/2023.
//

import Foundation
import FirebaseFirestore

struct VTransaction: Identifiable, Codable {
    var id = ""
    var storeId = ""
    var orderId = ""
    var amount = 0.0
    var amount_after_rate = 0.0
    var method = ""
    var date:Timestamp = Timestamp(date: Date())
    
    init(id: String = "", storeId: String = "", orderId: String = "", amount: Double = 0.0, amount_after_rate: Double = 0.0, method: String = "", date: Timestamp) {
        self.id = id
        self.storeId = storeId
        self.orderId = orderId
        self.amount = amount
        self.amount_after_rate = amount_after_rate
        self.method = method
        self.date = date
    }
}
