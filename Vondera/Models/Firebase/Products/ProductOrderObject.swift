//
//  ProductOrderObject.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import Foundation

struct ProductOrderObject : Codable {
    var orderId:String = ""
    var quantity:Int = 0
    
    init(orderId: String, quantity: Int) {
        self.orderId = orderId
        self.quantity = quantity
    }
}
