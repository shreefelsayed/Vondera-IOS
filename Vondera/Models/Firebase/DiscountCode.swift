//
//  DiscountCode.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation
import FirebaseFirestore


struct DiscountCode : Codable, Identifiable {
    var id = ""
    var maxUsed = 100
    var currentUsed = 0
    var listUsers = [String]()
    var active = true
    var discount = 0.1 //10%
    var addBy = ""
    var date = Timestamp(date: Date())
    var referId = ""
}
