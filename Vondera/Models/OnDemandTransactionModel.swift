//
//  OnDemandPlanRecharge.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/09/2024.
//

import Foundation

struct OnDemandTransactionModel: Codable {
    var id: String
    var uId: String
    var by: String
    var actionBy: String
    var desc: String
    var amount: Double
    var method: String
    var planId: String
    var subPlanId: String
    var mId: String
    var count: Int
    var date: Date
    var promoCode: String
}
