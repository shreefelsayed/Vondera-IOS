//
//  CourierIfno.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/02/2024.
//

import Foundation

struct CourierInfo : Codable, Hashable {
    var receiptId:String? = ""
    var courierHandler:String? = ""
    
    init(receiptId: String? = nil, courierHandler: String? = nil) {
        self.receiptId = receiptId
        self.courierHandler = courierHandler
    }
    
}
