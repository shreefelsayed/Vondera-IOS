import Foundation

struct CourierPrice: Codable, Equatable, Hashable {
    var govName: String = ""
    var price: Int = 0
    
    init() {}
    
    init(govName: String, price: Int) {
        self.govName = govName
        self.price = price
    }
    
    static func ==(lhs: CourierPrice, rhs: CourierPrice) -> Bool {
        return lhs.govName == rhs.govName
    }
}
