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

    var ownerId: String = ""
    var cardToken: String? = ""
    var addBy: String? = ""
    
    var active: Bool? = true
    
    var fbLink: String? = ""
    var instaLink: String? = ""
    var tiktokLink: String? = ""
    var website: String? = ""
    
 
    var onlineStore: Bool? = true
    var offlineStore: Bool? = true
    var canOrder: Bool? = true
    var onlyOnline: Bool? = false
    var localWhatsapp: Bool? = true
    var canWorkersReset: Bool? = false
    var orderAttachments: Bool? = false
    var canEditPrice: Bool? = false
    var canPrePaid: Bool? = true
    var websiteEnabled: Bool? = true
    var cantOpenPackage: Bool? = false
    var chatEnabled: Bool? = true
    var sellerName:Bool? = false
    
    var customMessage: String? = ""

    var date: Date = Date()

    var ios:Bool? = true
    
    var wallet: Int? = 0 // Cashback wallet
    var ordersCount: Int? = 0
    var couriersCount: Int? = 0
    var clientsCount: Int? = 0
    var employeesCount: Int? = 0
    var productsCount: Int? = 0
    var categoriesCount: Int? = 0
    var agelWallet: Int? = 0
    var almostOut:Int? = 0
    var categoryNo:Int? = 0
    
    var listMarkets:[StoreMarketPlace]? = MarketsManager().getDefaultMarkets()
    var listAreas: [CourierPrice]? = GovsUtil().getStoreDefault()

    
    var siteData:SiteData? = SiteData()
    var whatsappPojo: WhatsappPojo? = WhatsappPojo()
    var shopify: ShopifyPojo? = ShopifyPojo()
    var subscribedPlan: SubscribedPlan?
    var ordersCountObj: OrdersCount? = OrdersCount()
    var paymentOptions: PaymentsOptions? = PaymentsOptions()

    init() {
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
    
    func storeLink() -> String {
        return "https://vondera.store/\(merchantId)"
    }
    
    func storeLinkURL() -> URL {
        return URL(string: storeLink()) ?? URL(string: "https://vondera.app")!
    }
    
    func linkQrCodeData() -> Data? {
        return storeLink().qrCodeData
    }
}

extension Store {
    static func Qotoofs() -> String {
        return "lcvPuRAIVVUnRcZpttlPsRPLqoY2"
    }
    
    
    static func example() -> Store {
        let store = Store(name: "Adore", address: "14 El Nozha St", governorate: "Cairo", phone: "01114077125", subscribedPlan: SubscribedPlan.example(), ownerId: "")
        store.id = ""
        store.agelWallet = 72000
        store.merchantId = "58392032"
        return store
    }
}
