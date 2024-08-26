//
//  Client.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Client: Codable, Hashable, Identifiable {
    @DocumentID var id:String?
    var phone: String = ""
    var name: String = ""
    var address: String? = ""
    var gov: String? = ""
    var otherPhone: String? = ""
    var ordersCount: Int? = 0
    var total: Double? = 0
    var banned: Bool? = false
    var lastOrder:Timestamp? = Timestamp(date: Date())
}

extension Client {
    static func example() -> Client {
        return Client(name: "Shreif El Sayed", gov: "Cairo", ordersCount: 123, total: 5600)
    }
}
