import Foundation

struct WhatsappPojo: Codable {
    var productId: String = ""
    var token: String = ""
    var sessionId: String = ""
    var active: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case productId
        case token
        case sessionId
        case active
    }
    
    init() {}
}
