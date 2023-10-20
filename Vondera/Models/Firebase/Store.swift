import Foundation
import FirebaseFirestoreSwift
class Store: Codable {
    @DocumentID var id:String?
    var name: String = ""
    var slogan: String? = ""
    var address: String = ""
    var governorate: String = ""
    var phone: String = ""
    var logo: String? = ""
    var merchantId: String = ""
    var whatsappPojo: WhatsappPojo? = WhatsappPojo()
    var shopify: ShopifyPojo? = ShopifyPojo()
    var subscribedPlan: SubscribedPlan?
    var ownerId: String = ""
    var cardToken: String? = ""
    var active: Bool? = true
    var addBy: String? = ""
    var wallet: Int? = 0
    var fbLink: String? = ""
    var instaLink: String? = ""
    var tiktokLink: String? = ""
    var website: String? = ""
    var canOrder: Bool? = true
    var onlyOnline: Bool? = false
    var localWhatsapp: Bool? = true
    var canWorkersReset: Bool? = false
    var orderAttachments: Bool? = false
    var canEditPrice: Bool? = false
    var canPrePaid: Bool? = true
    var websiteEnabled: Bool? = false
    var cantOpenPackage: Bool? = false
    var chatEnabled: Bool? = true
    var ordersCount: Int? = 0
    var categoryNo:Int? = 0
    var couriersCount: Int? = 0
    var clientsCount: Int? = 0
    var employeesCount: Int? = 0
    var productsCount: Int? = 0
    var categoriesCount: Int? = 0
    var date: Date = Date()
    var onlineStore: Bool? = true
    var offlineStore: Bool? = true
    var customMessage: String? = ""
    var listAreas: [CourierPrice]? = GovsUtil().getStoreDefault()
    var ordersCountObj: OrdersCount? = OrdersCount()
    var almostOut:Int? = 0
    
    init() {
    }
    
    enum CodingKeys: String, CodingKey {
            case name, slogan, address, governorate, phone, logo, merchantId, whatsappPojo, shopify
            case subscribedPlan, ownerId, cardToken, active, addBy, wallet, fbLink, instaLink, tiktokLink
            case website, canOrder, onlyOnline, localWhatsapp, canWorkersReset, orderAttachments
            case canEditPrice, canPrePaid, cantOpenPackage, chatEnabled, ordersCount, couriersCount
            case clientsCount, employeesCount, productsCount, categoriesCount, date, onlineStore
            case offlineStore, customMessage, listAreas, ordersCountObj, almostOut, websiteEnabled, categoryNo
    }
    
    init(name: String, address: String, governorate: String, phone: String, subscribedPlan: SubscribedPlan, ownerId: String) {
        self.name = name
        self.address = address
        self.governorate = governorate
        self.phone = phone
        self.subscribedPlan = subscribedPlan
        self.ownerId = ownerId
    }
    
    
    
    func finishedSteps() -> Bool {
        return !(logo?.isEmpty ?? true) && ordersCount ?? 0 > 0 && productsCount ?? 0 > 0 && categoriesCount ?? 0 > 0 && couriersCount ?? 0 > 0 && listAreas?.count ?? 0 > 0
    }
    
    func QuoteExceeded() -> Bool {
        if subscribedPlan == nil {return true}
        if subscribedPlan!.expired {return true}
        return subscribedPlan!.currentOrders >= subscribedPlan!.maxOrders
        
    }
}

extension Store {
    static func Qotoofs() -> String {
        return "lcvPuRAIVVUnRcZpttlPsRPLqoY2"
    }
    static func example() -> Store {
        let store = Store(name: "Adore", address: "14 El Nozha St", governorate: "Cairo", phone: "01114077125", subscribedPlan: SubscribedPlan(), ownerId: "")
        store.id = ""
        return store
    }
}
