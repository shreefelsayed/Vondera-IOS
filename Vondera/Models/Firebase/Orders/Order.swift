//
//  Order.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import SwiftUI


// Statue Enum
enum OrderStatues:String, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case assembled = "Assembled"
    case withCourier = "Out For Delivery"
    case failed = "Failed"
    case delivered = "Delivered"
    case deleted = "Deleted"
}

struct Order: Codable, Identifiable, Equatable {
    var id: String = ""
    var name: String = ""
    var phone: String = ""
    var otherPhone: String? = ""
    var gov: String = ""
    var address: String = ""
    var notes: String? = ""
    var owner: String? = ""
    
    var date:Timestamp = Timestamp(date: Date())
    var dateConfirm: Timestamp?
    var dateShipping: Timestamp?
    var dateDelivered: Timestamp?
    var dateAssembled: Timestamp?
    var dateConfirmed: Timestamp?
    
    var courierId: String? = ""
    var addBy: String = ""
    var workedBy: String? = ""
    
    var statue: String = "Pending" //Pending - Confirmed - Assembled - Out For Delivery - Delivered - Failed - Deleted
    
    // --> Market Place
    var marketPlaceId: String? = ""
    
    var discount: Double? = 0
    var clientShippingFees: Double = 0
    var courierShippingFees: Double? = 0
    var commission: Double? = 0
    var salesTotal:Double? = 0
    
    var lat: Double? = 0
    var lang: Double? = 0
    var deposit:Double? = 0
    
    var percPaid: Bool? = false
    var part: Bool? = false
    var paid: Bool? = false
    
    var listProducts: [OrderProductObject]? = []
    var listAttachments: [String]? = []
    var listUpdates: [Updates]? = []
    
    var courierName: String? = ""
    var storeId: String? = ""
    var requireDelivery: Bool? = true
    var shopify: Bool? = false
    var email:String? = ""
    var hidden:Bool? = false
    
    var payment:OrderPayment? = OrderPayment()
    var courierInfo:CourierInfo?
    
    //init() {}
    
    init(id: String, name: String, address: String, phone: String, gov: String, notes: String, discount: Double?, clientShippingFees: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.gov = gov
        self.notes = notes
        self.discount = discount
        self.clientShippingFees = clientShippingFees
    }
    
    static func getNotFoundMessage(statue:String) -> LocalizedStringKey {
        switch OrderStatues(rawValue: statue) {
            case .pending :
            return "Sorry :(\nThere is no new orders in your store."
            case .confirmed :
            return "You have no orders that were confirmed with your customers."
            case .assembled :
            return "There is no ready orders in your store, assemble some orders to get them ready"
            case .withCourier :
            return "We are all good\nThere is no orders are still pending with couriers"
            case .delivered :
            return "No orders were delivered to your clients yet"
            case .failed :
            return "We are all good\nThere is no failed orders in your store"
            case .deleted :
            return "You have no deleted orders in your store"
            case .none:
                return ""
        }
    }
    
    static func getNotFoundResource(statue:String) -> ImageResource {
        switch OrderStatues(rawValue: statue) {
            case .pending :
            return .pendingOrders
            case .confirmed :
                return .ordersConfirmed
            case .assembled :
                return .ordersReady
            case .withCourier :
                return .orderWithCourier
            case .delivered :
                return .ordersDelivered
            case .failed :
                return .ordersFailed
            case .deleted :
                return .ordersDeleted
            case .none:
                return .pendingOrders
        }
    }
    
    func getStatueLocalized() -> LocalizedStringKey {
        switch statue {
        case "Pending" :
            return "Pending"
        case "Confirmed" :
            return "Confirmed"
        case "Assembled" :
            return "Assembled"
        case "Out For Delivery" :
            return "Out For Delivery"
        case "Delivered" :
            return "Delivered"
        case "Failed" :
            return "Failed"
        case "Deleted" :
            return "Deleted"
            
        default :
            return "".localize()
        }
    }
    
    var netProfitFinal: Double {
        if statue == "Failed" && (part != nil) && part == false {
            return netProfit
        } else if statue == "Failed" && !(part ?? false) {
            return clientShippingFees - (courierShippingFees ?? 0)
        } else {
            return netProfit
        }
    }
    
    var netProfit: Double {
        return COD  - (courierShippingFees ?? 0) - finalCommission - buyingPrice
    }
    
    var CODAfterCourier: Double {
        if statue == "Failed" {
            return 0 - (courierShippingFees ?? 0)
        }
        
        return COD - (courierShippingFees ?? 0)
    }
    
    var finalCommission: Double {
        if statue != "Failed" {
            return commission ?? 0
        } else {
            return 0
        }
    }
    
    var finalSelling: Double {
        if statue == "Delivered" {
            return COD - (courierShippingFees ?? 0) - finalCommission
        } else {
            return COD
        }
    }
    
    var totalPrice: Double {
        if listProducts == nil {return 0}
        
        var total: Double = 0
        for product in listProducts! {
            total += product.price * product.quantity.double()
        }
        return total
    }
    
    var buyingPrice: Double {
        if statue == "Failed" && !(part ?? false) {
            return 0
        }
        
        var total: Double = 0
            
        if let listProducts = listProducts {
            for product in listProducts {
                total += product.buyingPrice * product.quantity.double()
            }
        }
        return total
    }
    
    var COD: Double {
        return totalPrice - (discount ?? 0) + clientShippingFees - (deposit ?? 0)
    }
    
    var orderPrice: Double {
        return totalPrice - (discount ?? 0) + clientShippingFees
    }
    
    var amountToGet:Double {
        return COD - (deposit ?? 0)
    }
    
    var quantity: Int {
        var total = 0
        if let listProducts = listProducts {
            for product in listProducts {
                total += product.quantity
            }
        }
        return total
    }
    
    var isOrderHadMoney: Bool {
        if statue == "Delivered" {
            return true
        } else {
            return statue == "Failed" && (part != nil) && part!
        }
    }
    
    var getPaymentStatue : LocalizedStringKey {
        if isOrderHadMoney {
            return "Paid"
        } else if (deposit ?? 0) >= orderPrice && (deposit ?? 0) != 0{
            return "Prepaid"
        } else if (deposit ?? 0) > 0 {
            return "Deposit"
        } else if orderPrice == 0 {
            return "Free"
        } else {
            return "Not Paid"
        }
    }
    
    var isHidden: Bool {
        guard let hidden = hidden else { return false }
        return hidden
    }
    
    var getPaymentStatueColor: Color {
        if isOrderHadMoney {
            return .green
        } else if (deposit ?? 0) >= orderPrice && (deposit ?? 0) != 0{
            return .yellow
        } else if (deposit ?? 0) > 0 {
            return .orange
        } else if orderPrice == 0 {
            return .blue
        } else {
            return .red
        }
    }
    
    var defaultPhoto: String {
        if let listProducts = listProducts, !listProducts.isEmpty {
            return listProducts[0].image
        }
        
        return ""
    }
    
    var productsCount: Int {
        var count = 0
        if let listProducts = listProducts {
            for orderProductObject in listProducts {
                count += orderProductObject.quantity
            }
        }
        
        return count
    }
    
    var productsInfo: String {
        if listProducts == nil {return ""}
        
        var str = ""
        if let listProducts = listProducts {
            for productOrderObject in listProducts {
                str += productOrderObject.name
                if !productOrderObject.getVarientsString().isBlank {
                    str += " ( \(productOrderObject.getVarientsString() ) "
                }
                str += " x \(productOrderObject.quantity)\n"
            }
        }
        return str
    }
    
    var canShippingInfoEdit: Bool {
        return statue == "Pending" || statue == "Confirmed" || statue == "Assembled"
    }
    
    func getSellingPrice() -> Double {
        if statue == "Failed" && !(part ?? false) {
            return 0
        }
        
        var totalMoney: Double = 0
        if let listProducts = listProducts {
            listProducts.forEach { product in
                totalMoney += product.price * Double(product.quantity)
            }
        }
        
        return Double(totalMoney - (discount ?? 0))
    }
    
    
    
    func getMargin() -> String {
        var cost = 0.0
        let totalPrice = getSellingPrice()
        
        if let listProducts = listProducts {
            for item in listProducts {
                cost += Double(item.buyingPrice)
            }
        }
        
        let margin =  ((totalPrice - cost) / totalPrice) * 100
        return String(format: "%.1f", margin)
    }
    
    func getPaidStatue() -> (LocalizedStringKey, Color) {
        if let paid = paid, paid {
            return ("Prepaid", Color.yellow)
        }
        
        if statue == "Delivered" {
            return ("Paid", Color.green)
        }
        
        return ("Not Paid", Color.red)
    }
    
    func canCollectMoney() -> Bool {
        if isFinished() { return false }
        return COD > 0
    }
    
    func isFinished() -> Bool {
        if statue == "Delivered" || statue == "Failed" || statue == "Deleted" {
            return true
        }
        
        return false
    }
    
    func getLink() -> URL? {
        if let link = UserInformation.shared.user?.store?.getStoreDomain(), let siteEnabled =  UserInformation.shared.user?.store?.websiteEnabled, siteEnabled == true {
            if let url = URL(string: "\(link)/order-summary/\(id)") {
                return url
            }
        }
        
        return nil
    }
    
    func canEditProducts(accountType: String) -> Bool {
        if accountType == "Marketing" && statue == "Pending" {
            return true
        } else {
            return accountType != "Marketing" && canShippingInfoEdit
        }
    }
    
    func canEditPrice() -> Bool {
        if statue == "Delivered" || statue == "Failed" {
            return false
        }
        
        return true
    }
    
    func canDeleteOrder(accountType: String) -> Bool {
        if statue == "Deleted" {
            return false
        }
        if accountType == "Marketing" && statue == "Pending" {
            return true
        } else if accountType != "Marketing" && canShippingInfoEdit {
            return true
        } else {
            return accountType == "Store Admin" || accountType == "Owner"
        }
    }
    
    func getCurrentStep() -> Int {
        switch statue {
        case "Pending":
            return 1
        case "Confirmed":
            return 2
        case "Assembled" :
            return 3
        case "Out For Delivery" :
            return 4
        case "Delivered":
            return (requireDelivery ?? true) ? 5 : 4
        case "Failed":
            return (requireDelivery ?? true) ? 5 : 4
        default:
            return 0
        }
        
        
    }
    func getOrderSteps() -> [String] {
        if (requireDelivery ?? true) {
            if statue == "Failed" && !(part ?? false) {
                return ["Pending", "Confirmed", "Ready", "With Courier", "Failed"]
            } else {
                return ["Pending", "Confirmed", "Ready", "With Courier", "Delivered"]
            }
        } else {
            if statue == "Failed" && !(part ?? false) {
                return ["Pending", "Confirmed", "Ready", "Failed"]
            } else {
                return ["Pending", "Confirmed", "Ready", "Delivered"]
            }
        }
    }
    
    static func ==(lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Order {
    func filter(searchText:String) -> Bool {
        if searchText.isBlank {
            return true
        }
        
        return self.id.localizedCaseInsensitiveContains(searchText)
        || self.name.localizedCaseInsensitiveContains(searchText)
        || self.phone.localizedCaseInsensitiveContains(searchText)
        || (self.otherPhone ?? "").localizedCaseInsensitiveContains(searchText)
        || self.gov.localizedCaseInsensitiveContains(searchText)
        || self.address.localizedCaseInsensitiveContains(searchText)
    }
    
    func toString() -> String {
        var str = ""
        str = str + "Order NO. \(self.id) \n"
        str = str + "Client Name. \(self.name) \n"
        str = str + "Client Phone. \(self.phone) \n"
        if !(self.otherPhone?.isEmpty ?? true) {
            str = str + "Client Other phone. \(self.otherPhone!) \n"
        }
        str = str + "Client address. \(self.gov), \(self.address) \n"
        str = str + "Products. \(self.productsInfo) \n"
        if(self.deposit != nil && self.deposit! > 0) {str = str + "Deposit. \(self.deposit ?? 0) \n"}
        str = str + "COD. \(self.COD) LE"
        if let link = getLink() {
            str = str + "Link : \(link.absoluteString)"
        }
        
        
        return str
    }
    
    static func example() -> Order {
        var order = Order(id: "2994302", name: "Shreif El Sayed", address: "15 El Emam Ali St.", phone: "01551542514", gov: "Cairo", notes: "", discount: 0, clientShippingFees: 50)
        let product:OrderProductObject = OrderProductObject.example()
        order.listProducts = [product]
        order.marketPlaceId = "instagram"
        return order
    }
    
}

struct OrderPayment : Codable {
    var paid:Bool? = false
    var gateway:String? = "COD"
    var transId:String? = ""
    var paymentMethod:String? = "COD"
}
