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
    
    var discount: Int? = 0
    var clientShippingFees: Int = 0
    var courierShippingFees: Int? = 0
    var commission: Int? = 0
    
    var lat: Double? = 0
    var lang: Double? = 0
    var deposit:Int? = 0
    
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
    
    //init() {}
    
    init(id: String, name: String, address: String, phone: String, gov: String, notes: String, discount: Int, clientShippingFees: Int) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.gov = gov
        self.notes = notes
        self.discount = discount
        self.clientShippingFees = clientShippingFees
    }
    
    func getStatueLocalized() -> LocalizedStringKey {
        switch statue {
            //Pending - Confirmed - Assembled - Out For Delivery - Delivered - Failed - Deleted
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
    
    var netProfitFinal: Int {
        if statue == "Failed" && (part != nil) && part == false {
            return netProfit
        } else if statue == "Failed" && !(part ?? false) {
            return clientShippingFees - (courierShippingFees ?? 0)
        } else {
            return netProfit
        }
    }
    
    var netProfit: Int {
        return Int(COD  - (courierShippingFees ?? 0) - finalCommission - buyingPrice)
    }
    
    var CODAfterCourier: Int {
        if statue == "Failed" {
            return 0 - (courierShippingFees ?? 0)
        }
        
        return Int(COD - (courierShippingFees ?? 0))
    }
    
    var finalCommission: Int {
        if statue != "Failed" {
            return (commission ?? 0)
        } else {
            return 0
        }
    }
    
    var finalSelling: Int {
        if statue == "Delivered" {
            return Int(COD - (courierShippingFees ?? 0) - finalCommission)
        } else {
            return COD
        }
    }
    
    var totalPrice: Int {
        if listProducts == nil {return 0}
        
        var total: Int = 0
        for product in listProducts! {
            total += Int(product.price) * product.quantity
        }
        return total
    }
    
    var buyingPrice: Int {
        if statue == "Failed" && !(part ?? false) {
            return 0
        }
        
        var total: Int = 0
            
        if let listProducts = listProducts {
            for product in listProducts {
                total += Int(product.buyingPrice) * product.quantity
            }
        }
        return total
    }
    
    var COD: Int {
        return totalPrice - (discount ?? 0) + clientShippingFees
    }
    
    var amountToGet:Int {
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
        
        return (totalMoney - Double((discount ?? 0)))
    }
    
    func canEditProducts(accountType: String) -> Bool {
        if accountType == "Marketing" && statue == "Pending" {
            return true
        } else {
            return accountType != "Marketing" && canShippingInfoEdit
        }
    }
    
    var latLang: CLLocationCoordinate2D? {
        if let lat = lat, let lang = lang, lang != 0, lat != 0 {
            return CLLocationCoordinate2D(latitude: lat, longitude: lang)
        }
        
        return nil
    }
    
    func canEditPrice() -> Bool {
        if statue == "Delivered" || statue == "Failed" {
            return false
        }
        
        return true
    }
    
    func getMargin() -> String {
        var cost = 0.0
        let totalPrice = getSellingPrice()
        
        if let listProducts = listProducts {
            for item in listProducts {
                cost += item.buyingPrice
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
    
    func getLink(mId:String) -> URL {
        let link = "https://vondera.store/order?store=\(mId)&id=\(id)"
        return URL(string: link)!
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
        
        
        return str
    }
    
    static func example() -> Order {
        var order = Order(id: "2994302", name: "Shreif El Sayed", address: "15 El Emam Ali St.", phone: "01551542514", gov: "Cairo", notes: "", discount: 0, clientShippingFees: 50)
        let product:OrderProductObject = OrderProductObject.example()
        order.listProducts = [product]
        return order
    }
    
    func getCurrentStep() -> Int {
        var step = 0
        switch self.statue {
        case "Pending" :
            step = 0
        case "Confirmed":
            step = 1
        case "Assembled":
            step = 2
        case "Out For Delivery" :
            step = 3
        case "Delivered" :
            step = 4
        case "Failed":
            step = 4
        default:
            step = 0
        }
        
        return step
    }
    
}
