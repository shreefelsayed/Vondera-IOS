import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct UserData: Codable, Identifiable {
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var storeId: String = ""
    var phone: String = ""
    var addedBy: String? = ""
    var accountType: String = "Worker" // Owner - Store Admin - Marketing - Worker - Courier
    var active: Bool = true
    var pass: String = ""
    var userURL: String = ""
    var wallet: Int? = 0
    var username: String? = ""
    var percentage: Double? = 0
    var earnings: Int? = 0
    var online: Bool? = false
    var date: Timestamp? = Timestamp(date: Date())
    var ordersCount: Int? = 0
    var listDevices: [String]? = []
    var notiSettings: NotiSettingPojo? = NotiSettingPojo()
    var facebookId: String? = ""
    var googleId: String? = ""
    var appleId:String? = ""
    var store: Store?
    var storesCount: Int? = 0
    var numberVerfied: Bool? = false
    var messageCounter: Int? = 0
    var ios: Bool? = true
    var accessLevels:AccessLevels? = AccessLevels()
    
    init() {}
    
    init(id: String, name: String, email: String, phone: String, addedBy: String, accountType: String, pass: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.addedBy = addedBy
        self.accountType = accountType
        self.pass = pass
    }
    
    var isStoreUser:Bool {
        return accountType == "Owner" || accountType == "Store Admin" || accountType == "Marketing" || accountType == "Worker" || accountType == "Courier"
    }
    
    var isShreif: Bool {
        return email == "admin@armjld.co"
    }
    
    func connectedToFB() -> Bool {
        return !(facebookId?.isBlank ?? true)
    }
    
    func connectedToGoogle() -> Bool {
        return !(googleId?.isBlank ?? true)
    }
    func connectedToApple() -> Bool {
        return !(appleId?.isBlank ?? true)
    }
    
    func isAppleAccount() -> Bool {
        return email == "shreiftest@gmail.com"
    }
    
    static func ==(lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension UserData {
    func getAccountTypeString() -> LocalizedStringKey {
        if self.accountType == "Store Admin" {
            return "Store Admin"
        } else if self.accountType == "Owner" {
            return "Store Owner"
        } else if self.accountType == "Worker" {
            return "Employee"
        } else if self.accountType == "Marketing" {
            return "Sales"
        }
        return ""
    }
}

extension UserData {
    func filter(_ searchText:String) -> Bool {
        if searchText.isBlank {
            return true
        }
        
        return self.name.localizedCaseInsensitiveContains(searchText) ||
        self.phone.localizedCaseInsensitiveContains(searchText)
    }
    
    static func example() -> UserData {
        var user =  UserData(id: "HFKPDSPKFDSPK3420ifdDFSSD", name: "Shreif El Sayed", email: "armjldtrainer@gmail.com", phone: "01551542514", addedBy: "", accountType: "Owner", pass: "123456")
        user.ordersCount = 122
        user.store = Store.example()
        user.storeId = ""
        return user
    }
    
    func stringAccountType() -> LocalizedStringKey {
        switch self.accountType {
        case "Owner" :
            return "Store Owner"
        case "Store Admin":
            return "Store Admin"
        case "Admin":
            return "App Admin"
        case "Marketing":
            return "Sales Employee"
        case "Worker":
            return "Employee"
        default :
            return ""
        }
    }
}

enum UserRoles: String, CaseIterable {
    case admin = "Store Admin"
    case modrator = "Marketing"
    case employee = "Worker"
    case accountant = "Accountant"
    
    func getDisplayName() -> LocalizedStringKey {
        switch self {
        case .admin:
            "Store Admin"
        case .modrator:
            "Page Modrator"
        case .employee:
            "Employee"
        case .accountant:
            "Accountant"
        }
    }
    
    func getRoleDesc() -> LocalizedStringKey {
        switch self {
        case .admin:
            "Store admin mostly have access to all the of the store settings"
        case .modrator:
            "A user that normally responds to messages in your social media"
        case .employee:
            "A user which is responsible on packing or operating the store"
        case .accountant:
            "A user the is responsible for accounting and tracking expanses and profit"
        }
    }
    
    func getDefaultAccessLevel() -> AccessLevels {
        switch self {
        case .admin:
            return AccessLevels().getAdminDefault()
        case .modrator:
            return AccessLevels().getMarketingDefault()
        case .employee:
            return AccessLevels().getEmployeeDefault()
        case .accountant:
            return AccessLevels().getAccountantDefault()
        }
    }
}
