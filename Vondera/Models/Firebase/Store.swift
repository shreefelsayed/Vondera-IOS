import Foundation
import FirebaseFirestoreSwift
import SwiftUI

class Store: Codable {
    @DocumentID var id:String?
    var name: String = ""
    var address: String = ""
    var governorate: String = ""
    var phone: String = ""
    var merchantId: String = ""
    var ownerId: String = ""
    
    var cardToken: String? = ""
    var addBy: String? = ""
    var logo: String? = ""
    var slogan: String? = ""

    var active: Bool? = true
    var renewCount:Int? = 0
    
    var fbLink: String? = ""
    var instaLink: String? = ""
    var tiktokLink: String? = ""
    var website: String? = ""
    var customDomain:String? = ""
    var ordersWallet:Double? = 0.0
    
 
    var onlineStore: Bool? = true
    var offlineStore: Bool? = true
    var canOrder: Bool? = true
    var onlyOnline: Bool? = false
    var localWhatsapp: Bool? = true
    var canWorkersReset: Bool? = false
    var orderAttachments: Bool? = false
    var canEditPrice: Bool? = false
    var localOutOfStock:Bool? = false
    var canPrePaid: Bool? = true
    var websiteEnabled: Bool? = true
    var cantOpenPackage: Bool? = false
    var chatEnabled: Bool? = true
    var sellerName:Bool? = false
    var printSerial:Bool? = false
    
    var customMessage: String? = ""

    var date: Date = Date()

    var ios:Bool? = true
    
    var wallet: Int? = 0 // Cashback wallet
    var vPayWallet:Double? = 0.0
    var ordersCount: Int? = 0
    var couriersCount: Int? = 0
    var clientsCount: Int? = 0
    var employeesCount: Int? = 0
    var productsCount: Int? = 0
    var categoriesCount: Int? = 0
    var agelWallet: Int? = 0
    var almostOut:Int? = 0
    var categoryNo:Int? = 0
    var hiddenOrders:Int? = 0
    
    var listMarkets:[StoreMarketPlace]? = MarketsManager().getDefaultMarkets()
    var listAreas: [CourierPrice]? = GovsUtil().getStoreDefault()

    
    var siteData:SiteData? = SiteData()
    var shopify: ShopifyPojo? = ShopifyPojo()
    var storePlanInfo: StorePlanInfo?
    var ordersCountObj: OrdersCount? = OrdersCount()
    var paymentOptions: PaymentsOptions? = PaymentsOptions()
    var emailService:EmailService? = EmailService()
    var wbInfo:WbInfo? = WbInfo()
    
    
    // --> Pixels
    var gtm:String? = ""
    var fbPixel:String? = ""
    
    init() {
    }
    
    init(name: String, address: String, governorate: String, phone: String, ownerId: String) {
        self.name = name
        self.address = address
        self.governorate = governorate
        self.phone = phone
        self.ownerId = ownerId
    }
    
    func finishedSteps() -> Bool {
        return !(logo?.isEmpty ?? true) && ordersCount ?? 0 > 0 && productsCount ?? 0 > 0 && categoriesCount ?? 0 > 0 && couriersCount ?? 0 > 0 && listAreas?.count ?? 0 > 0
    }
    
    func QuoteExceeded() -> Bool {
        if storePlanInfo == nil {return true}
        if storePlanInfo!.expired {return true}
        return storePlanInfo!.planFeatures.currentOrders >= storePlanInfo!.planFeatures.maxOrders
    }
        
    func getVonderaLink() -> String {
        return "https://" + merchantId + ".vondera.shop"
    }
    
    func getStoreDomain() -> String {
        if let domain = customDomain, !domain.isBlank {
            return "https://" + domain
        }
        
        return getVonderaLink()
    }
    
    func linkQrCodeData() -> Data? {
        return getStoreDomain().qrCodeData
    }
    
    func planWarning() -> LocalizedStringKey? {
        // Get the subscribed plan
        guard let storePlanInfo = storePlanInfo else {
            return nil
        }

        // If plan is free
        if storePlanInfo.planId == "free" {
            return "You're using the free plan"
        }

        // Get the current date
        if let expireData = storePlanInfo.expireDate?.toDate() {
            let currentDate = Date()

            // Calculate the difference in days between the expiration date and the current date
            let differenceInSeconds = expireData.timeIntervalSince(currentDate)
            
            let daysLeft = Int(differenceInSeconds / (60 * 60 * 24))

            // If the expiration date is within 3 days, return the number of days left
            if daysLeft <= 3 {
                return "Your subscription will expire in \(daysLeft) days"
            }
        }
       

        // Calculate remaining orders
        let remainingOrders = storePlanInfo.planFeatures.maxOrders - storePlanInfo.planFeatures.currentOrders

        // If remaining orders are less than 10% of the maximum orders
        if remainingOrders < Int(Double(storePlanInfo.planFeatures.maxOrders) * 0.1) {
            return "You've \(remainingOrders) orders left in your plan"
        }

        return nil
    }
}

struct EmailService: Codable {
    var email:String?
    var password:String?
    var service:String?
    var useDefaultMail:Bool? = true
}

extension Store {
    static func Qotoofs() -> String {
        return "lcvPuRAIVVUnRcZpttlPsRPLqoY2"
    }
    
    
    static func example() -> Store {
        let store = Store(name: "Adore", address: "14 El Nozha St", governorate: "Cairo", phone: "01114077125", ownerId: "")
        store.id = ""
        store.agelWallet = 72000
        store.merchantId = "58392032"
        return store
    }
}
