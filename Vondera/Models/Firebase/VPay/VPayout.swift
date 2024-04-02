//
//  VPayout.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/12/2023.
//

import Foundation
import FirebaseFirestore

struct VPayout: Identifiable, Codable {
    var id = ""
    var storeId = ""
    var mid:String? = ""
    var date:Timestamp = Timestamp(date: Date())
    var amount = 0.0
    var statue = "Pending" // Pending - Cancelled - Failed - Success
    var method = "instapay"
    var identifier = ""
    
    init(id: String = "", storeId: String = "", mid: String? = "", date: Timestamp, amount: Double = 0.0, statue: String = "Pending", method: String = "instapay", identifier: String = "") {
        self.id = id
        self.storeId = storeId
        self.mid = mid
        self.date = date
        self.amount = amount
        self.statue = statue
        self.method = method
        self.identifier = identifier
    }
}
