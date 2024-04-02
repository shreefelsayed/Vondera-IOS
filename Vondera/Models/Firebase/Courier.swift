//
//  Courier.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Courier: Codable, Identifiable, Equatable {
    var id: String = ""
    @ServerTimestamp var date: Timestamp?
    var name: String = ""
    var phone: String = ""
    var storeId: String? = ""
    var withCourier:Int? = 0
    var visible: Bool = true
    var listPrices: [CourierPrice] = [CourierPrice]()
    var imageUrl:String? = ""
    var courierHandler:String? = ""
    var sendDataToCompany:Bool? = false
    var autoUpdateOrderStatue:Bool? = false
    var updateCourierFee:Bool? = false
    var apiData:[String: String]? = [:]
    
    init(id:String, name:String, phone:String, storeId:String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.storeId = storeId
    }
    
    static func ==(lhs: Courier, rhs: Courier) -> Bool {
            return lhs.id == rhs.id
        }
}

extension Courier {
    static func example() -> Courier {
        return Courier(id: "", name: "Seal Express", phone: "01551542514", storeId: "")
    }
    
    func filter(_ searchText:String) -> Bool {
        return self.name.localizedCaseInsensitiveContains(searchText) ||
        self.phone.localizedCaseInsensitiveContains(searchText)
    }
}
