import Foundation

struct OrdersCount: Codable {
    var Pending: Int? = 0
    var Confirmed: Int? = 0
    var Assembled: Int? = 0
    var OutForDelivery: Int? = 0
    var Delivered: Int? = 0
    var Failed: Int? = 0
    var Deleted: Int? = 0
    
    init() {}

    
    var fulfill: Int {
        return (Pending ?? 0) + (Confirmed ?? 0) + (Assembled ?? 0)
    }
}
