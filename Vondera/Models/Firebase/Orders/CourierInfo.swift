//
//  CourierIfno.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/02/2024.
//

import Foundation

struct CourierInfo : Codable, Hashable {
    var receiptId:String? = ""
    var handler:String? = ""
    
    init(receiptId: String? = nil, handler: String? = nil) {
        self.receiptId = receiptId
        self.handler = handler
    }
    
}
