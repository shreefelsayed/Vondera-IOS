import Foundation

struct SubscribedPlan: Codable {
    var expireDate: Date = Date(timeIntervalSinceNow: 30 * 60 * 60 * 100)
    var startDate: Date = Date()
    var planName: String = "Free tair"
    var planId: String = "Ngub3Hv7wLNp9SJjTY3z"
    var currentOrders: Int = 0
    var maxOrders: Int = 25
    var onEnd: String = "Renew"
    var website:Bool? = false
    var expired: Bool = false
    var accessClient: Bool = false
    var accessCustomMessage: Bool = false
    var accessApis: Bool = false
    var employeesCount: Int = 0
    var accessStockReport: Bool = false
    var accessExpanses: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case expireDate
        case startDate
        case planName
        case planId
        case currentOrders
        case maxOrders
        case onEnd
        case expired
        case accessClient
        case accessCustomMessage
        case accessApis
        case employeesCount
        case accessStockReport
        case accessExpanses
        case website
    }
    
    init() {}
    
    func isFreePlan () -> Bool {
        return planId == "Ngub3Hv7wLNp9SJjTY3z"
    }
}
