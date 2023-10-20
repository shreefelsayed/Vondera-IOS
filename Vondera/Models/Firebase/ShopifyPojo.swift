import Foundation

struct ShopifyPojo: Codable {
    var apiKey: String = ""
    var appId: String = ""
    var id: String = ""
    var secret: String = ""
    var active: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case apiKey
        case appId
        case id
        case secret
        case active
    }
    
    init() {}
}
