import Foundation

class NotiSettingPojo: Codable {
    var newOrder: Bool = true
    var deletedOrder: Bool = true
    var stockFinished: Bool = true
    var newComplaint: Bool = true
    
    init() {}
    
    func convertToDictionary<T: Encodable>(_ object: T) -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            let data = try encoder.encode(object)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return dictionary
        } catch {
            print(error)
            return nil
        }
    }
    
}
