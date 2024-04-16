//
//  AppPlans.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/04/2024.
//

import Foundation
import FirebaseFirestore
import SwiftUI
struct PlanInfo : Codable {
    var id:String = ""
    var name:String = ""
    var desc:String = ""
    var planLevel:Int = 0
    var planFeatures = PlanFeatures()
    var planInfoPrices:[PlanInfoPrices] = []
    
    func getBasePrice() -> Int {
        return planInfoPrices.first?.price ?? 0
    }
    
    func getButtonTitle() -> LocalizedStringKey {
        let storePlanLevel = UserInformation.shared.user?.store?.storePlanInfo?.getPlanLevel() ?? 0
        let planLevel = getPlanLevel()
        
        if storePlanLevel == planLevel {
            return "Update subscribtion duration"
        } else if storePlanLevel < planLevel {
            return "Downgrade to \(name)"
        } else if storePlanLevel > planLevel {
            return "Upgrade to \(name)"
        }
        
        return ""
    }
    
    func getPlanLevel() -> Int {
        switch(id) {
        case "free":
            return 3
        case "starter":
            return 2
        case "plus":
            return 1
        case "pro":
            return 0
        default:
            return 3
        }
    }
    
    func getLowestPrice() -> Int {
        return planInfoPrices.last?.monthPrice() ?? 0
    }
}

struct Feature: Identifiable {
    var id = UUID()
    var name: LocalizedStringKey
    var available: Bool
}


extension PlanInfo {
    var features: [Feature] {
        var features: [Feature] = []
        features.append(Feature(name: "\(planFeatures.maxOrders) Orders / month", available: (self.planFeatures.maxOrders > 0)))
        features.append(Feature(name: "\(planFeatures.members) Team members", available: (self.planFeatures.members > 0)))
        features.append(Feature(name: "\(planFeatures.salesChannels) Sales Channels", available: (self.planFeatures.salesChannels > 0)))
        features.append(Feature(name: "Unlimited Products", available: true))
        features.append(Feature(name: "Build your website", available: planFeatures.website))
        features.append(Feature(name: "Get Product Reviews", available: planFeatures.reviews ))
        features.append(Feature(name: "Create Promo codes", available: planFeatures.discounts))
        features.append(Feature(name: "Integrate with shipping companies", available: planFeatures.couriers))
        features.append(Feature(name: "Add Payment gateways", available: planFeatures.payments))
        features.append(Feature(name: "Auto send whatsapp messages", available: planFeatures.whatsapp))
        features.append(Feature(name: "Connect your store to pixels", available: planFeatures.pixels))
        features.append(Feature(name: "Track your expanses", available: planFeatures.expanses))
        features.append(Feature(name: "Add Custom HTML Pages", available: planFeatures.customPages))
        features.append(Feature(name: "Global website / Multi languages", available: planFeatures.globalSite))
        features.append(Feature(name: "Create mail campaigns", available: planFeatures.mailCampaigns))
        features.append(Feature(name: "Annual plan free domain for one year", available: planFeatures.freeDomain))
        features.append(Feature(name: "Customers can create accounts", available: planFeatures.siteUsers))
        features.append(Feature(name: "Send abandon carts emails", available: planFeatures.abandonCarts))
        features.append(Feature(name: "Customize your receipt", available: planFeatures.customReceipt))
        return features
    }
}

struct StorePlanInfo: Codable {
    var planId = ""
    var name = ""
    var duration:Int = 0
    var trxId = ""
    var onEnd = "Cancel"
    var expireDate:Timestamp = Timestamp()
    var startDate:Timestamp = Timestamp()
    var expired = false
    var planFeatures = PlanFeatures()
    
    func getPercentage() -> Float {
        return max(0.0, min(1.0, Float(planFeatures.currentOrders) / Float(planFeatures.maxOrders)))
    }
    
    func isUsageAlert() -> Bool {
        return getPercentage() > 0.8
    }
    
    func isDateAlert() -> Bool {
        return expireDate.toDate().timeIntervalSince(Date()) <= 3 * 24 * 60 * 60
    }
    
    func isFreePlan () -> Bool {
        return planId == "free"
    }
    
    
    func getPlanLevel() -> Int {
        switch(planId) {
        case "free":
            return 3
        case "starter":
            return 2
        case "plus":
            return 1
        case "pro":
            return 0
        default:
            return 3
        }
    }
}

struct PlanInfoPrices: Codable, Identifiable {
    var id:String = ""
    var duration:Int = 30
    var price = 0
    
    func monthPrice() -> Int {
        return price / (duration / 30);
    }
    
    func getSaving(basePrice: Int) -> Int {
        guard basePrice > 0, (basePrice > monthPrice()) else { return 0 }
        let savingRatio = Double(basePrice - monthPrice()) / Double(basePrice)
        let saving = savingRatio * 100.0  // Convert to percentage
        return Int(saving)
    }
    
    
    
    func getDurationDisplay() -> LocalizedStringKey {
        switch(id) {
        case "month":
            return "1 Month"
        case "quartar":
            return "3 Months"
        case "year":
            return "One Year"
        default:
            return ""
        }
    }
}

struct PlanFeatures : Codable {
    var currentOrders: Int = 0
    var members: Int = 0 // DONE
    var salesChannels: Int = 0
    var maxOrders: Int = 15
    var website: Bool = false
    var reviews: Bool = false
    var discounts: Bool = false // DONE
    var couriers: Bool = false // DONE
    var payments: Bool = false // DONE
    var whatsapp: Bool = false
    var pixels: Bool = false // DONE
    var expanses: Bool = false // DONE
    var customPages: Bool = false // DONE
    var globalSite: Bool = false
    var mailCampaigns: Bool = false
    var freeDomain: Bool = false
    var siteUsers: Bool = false
    var abandonCarts: Bool = false
    var customReceipt: Bool = false // DONE
}

enum FeatureKeys {
    case maxOrders(Bool)
    case members, salesChannels, website, reviews, discounts, couriers, payments, whatsapp
    case pixels, expanses, customPages, globalSite, mailCampaigns, freeDomain, siteUsers, abandonCarts, customReceipt
    
    static var allCases: [FeatureKeys] {
            return [.maxOrders(true),
                    .members, .salesChannels, .website, .reviews,
                    .discounts, .couriers, .payments, .whatsapp,
                    .pixels, .expanses, .customPages, .globalSite,
                    .mailCampaigns, .freeDomain, .siteUsers,
                    .abandonCarts, .customReceipt]
        }
}

extension FeatureKeys {
    func getDrawable() -> ImageResource {
        switch self {
        case .members:
                .planEmployees
        case .salesChannels:
                .planSalesChannels
        case .maxOrders:
                .planOrders
        case .website:
                .planWebsite
        case .reviews:
                .planReviews
        case .discounts:
                .planDiscounts
        case .couriers:
                .planCouriers
        case .payments:
                .planPayments
        case .whatsapp:
                .planWhatsapp
        case .pixels:
                .planPixels
        case .expanses:
                .planExpanses
        case .customPages:
                .planCustomPages
        case .globalSite:
                .planGlobal
        case .mailCampaigns:
                .planMail
        case .freeDomain:
                .planDomain
        case .siteUsers:
                .planCustomers
        case .abandonCarts:
                .planCarts
        case .customReceipt:
                .planReceipts
        }
    }
    
    func getTitle() -> LocalizedStringKey {
        switch self {
        case .members:
            "You have reached team members limit"
        case .salesChannels:
            "You have reached sales channels limit"
        case .maxOrders:
            "You have reached order limit"
        case .website:
            "Enable website"
        case .reviews:
            "Product Reviews"
        case .discounts:
            "Discount Codes"
        case .couriers:
            "Shipping companies integration"
        case .payments:
            "Payment Gateways"
        case .whatsapp:
            "Whatsapp"
        case .pixels:
            "Pixels and conversions"
        case .expanses:
            "Expanses"
        case .customPages:
            "Custom HTML Pages"
        case .globalSite:
            "Global Website"
        case .mailCampaigns:
            "Mail Campaigns"
        case .freeDomain:
            "Domain"
        case .siteUsers:
            "Let your customers create accounts"
        case .abandonCarts:
            "Abandon Carts"
        case .customReceipt:
            "Customize your receipt"
        }
    }
    
    func getDesc() -> LocalizedStringKey {
        switch self {
        case .members:
            "You have reached your team members limit, upgrade your plan so you can add more members."
        case .salesChannels:
            "You have reached your sales channels limit, upgrade to be able to toggle new sales channels."
        case .maxOrders:
            "You have reached your plan's max orders limit, all new orders will be hidden until you subscribe."
        case .website:
            "Your website is active, but all it\'s orders are hidden, upgrade your plan to support the website orders."
        case .reviews:
            "Enable your customers to add reviews to your products."
        case .discounts:
            "Create your own customized discount codes, so your customer can get discounts."
        case .couriers:
            "Integrate with shipping companies, and always be up to date with the latest orders updates."
        case .payments:
            "Add your own payment gateway to your website."
        case .whatsapp:
            "Automatic send whatsapp messages, notifying the user about their order"
        case .pixels:
            "Connect your pixel trackers, Google TAG manager, Facebook Pixel, Tiktok Pixel, to keep track of your website conversion."
        case .expanses:
            "Adding expanses can help you track your net profit."
        case .customPages:
            "Create dynamic HTML pages in your website."
        case .globalSite:
            "Be Able to set your currency, and customize your site language and supported countries."
        case .mailCampaigns:
            "Send emails to your customers in bulk."
        case .freeDomain:
            "Get a free one year domain, and connect it to your store."
        case .siteUsers:
            "Keep track of your customers by letting them sign in to your store, and track their mails and carts easily"
        case .abandonCarts:
            "Send mail to customers notifying them about their abandon carts."
        case .customReceipt:
            "Customize your receipt by adding options to it, you can get summarize sheet with the required products, or a sheet with each city orders and more."
        }
    }
    
    func canAccess() -> Bool {
        guard let store = UserInformation.shared.user?.store, let features = UserInformation.shared.user?.store?.storePlanInfo?.planFeatures else {
            return false
        }
        
        switch self {
        case .members:
            return features.members > (store.employeesCount ?? 0)
        case .salesChannels:
            return true
        case .maxOrders(let hidden):
            return !hidden
        case .website:
            return features.website
        case .reviews:
            return features.reviews
        case .discounts:
            return features.discounts
        case .couriers:
            return features.couriers
        case .payments:
            return features.payments
        case .whatsapp:
            return features.whatsapp
        case .pixels:
            return features.pixels
        case .expanses:
            return features.expanses
        case .customPages:
            return features.customPages
        case .globalSite:
            return features.globalSite
        case .mailCampaigns:
            return features.mailCampaigns
        case .freeDomain:
            return features.freeDomain
        case .siteUsers:
            return features.siteUsers
        case .abandonCarts:
            return features.abandonCarts
        case .customReceipt:
            return features.customReceipt
        }
    }
}
