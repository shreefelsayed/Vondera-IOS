import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserData: Codable, Identifiable {
    var id: String = ""
    var name: String = ""
    var username: String? = ""
    var email: String = ""
    var storeId: String = ""
    var phone: String = ""
    var addedBy: String? = ""
    var accountType: String = "Worker" // Admin - Owner - Store Admin - Marketing - Worker
    var active: Bool = true
    var percentage: Double? = 0
    var pass: String = ""
    var userURL: String = ""
    var wallet: Int? = 0
    var earnings: Int? = 0
    var online: Bool? = false
    var date: Timestamp? = Timestamp(date: Date())
    var ordersCount: Int? = 0
    var listDevices: [String]? = []
    var notiSettings: NotiSettingPojo? = NotiSettingPojo()
    var facebookId: String? = ""
    var googleId: String? = ""
    var store: Store?
    var storesCount: Int? = 0
    var numberVerfied: Bool? = false
    var messageCounter: Int? = 0
    var ios: Bool? = true
    
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
        return accountType == "Owner" || accountType == "Store Admin" || accountType == "Marketing" || accountType == "Worker"
    }
    
    var canAccessAdmin:Bool {
        return accountType == "Store Admin" || accountType == "Owner"
    }
    
    var isShreif: Bool {
        return email == "admin@armjld.co"
    }
    
    static func ==(lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension UserData {
    func getAccountTypeString() -> String {
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
    
    func stringAccountType() -> String {
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

