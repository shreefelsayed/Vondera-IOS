import Foundation
import FirebaseFirestore
import SwiftUI

struct Updates: Codable, Hashable {
    var text: String = ""
    var uId: String = ""
    var date:Timestamp = Timestamp(date: Date())
    var code: Int? = 0
    
    init() {}
    
    init(text:String = "", uId: String, code: Int) {
        self.text = text
        self.uId = uId
        self.code = code
    }
}

extension Updates {
    static func example() -> Updates {
        return Updates(uId: "WFCL1aY0fTZ9mZwIpFLmheqkwel1", code: 10)
    }
    
    func desc() -> LocalizedStringKey {
        switch self.code {
        case 10:
            return "Order confirmed"
        case 12:
            return "Order was submitted"
        case 13:
            return "Deleted by us"
        case 15:
            return "Assigned to courier"
        case 16:
            return "Delivered to the client"
        case 17:
            return "Failed to delivered the order"
        case 18:
            return "Order is partial returned"
        case 19:
            return "Order infos was edited"
        case 20:
            return "Ready to be shipped"
        case 21:
            return "Shipping price changed"
        case 25:
            return "Order was reseted to intial value"
        default:
            return LocalizedStringKey(self.text)
        }
    }
}
