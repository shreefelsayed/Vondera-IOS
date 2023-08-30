import Foundation

class NotiSettingPojo: Codable {
    var newOrder: Bool = true
    var deletedOrder: Bool = true
    var stockFinished: Bool = true
    var newComplaint: Bool = true
    
    init() {}
}
