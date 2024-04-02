import Foundation

struct OrderProductObject: Codable, Hashable {
    var productId: String  = ""
    var name: String = ""
    var storeId: String = ""
    var quantity: Int = 0
    var price: Int = 0
    var image: String = ""
    var buyingPrice: Int = 0
    var hashVaraients: [String: String] = [:]
    var savedItemId: String = ""
    var product: StoreProduct?
    
    init() {}
    
    init(productId: String, name: String, storeId: String, quantity: Int, price: Int, image: String, buyingPrice: Int, hashVaraients: [String: String], savedItemId: String, product: StoreProduct) {
            self.productId = productId
            self.name = name
            self.storeId = storeId
            self.quantity = quantity
            self.price = price
            self.image = image
            self.buyingPrice = buyingPrice
            self.hashVaraients = hashVaraients
            self.savedItemId = savedItemId
            self.product = product
    }
    

    func getVarientsString() -> String {
        if hashVaraients.isEmpty {
            return ""
        }
        
        let listKeys = getVaraintsTitle()
        var str = ""
        for s in listKeys {
            str += "\(s) : \(String(describing: hashVaraients[s] ?? ""))"
            if listKeys.last != s {
                str += " , "
            }
        }
        return str
    }
    
    func getVaraintsTitle() -> [String] {
        if hashVaraients.isEmpty { return [String]() }
        let keys = Array(hashVaraients.keys)
        return keys
    }
    
    func getProfit() -> Int {
        return Int(price - buyingPrice)
    }
    
    func getMargin() -> Double {
        if buyingPrice == 0 {
            return 100.0
        }
        
        let margin =  ((price / buyingPrice) * 100)
        return Double(String(format: "%.1f", margin)) ?? 0.0
    }
    
    
    enum CodingKeys: String, CodingKey {
        case productId, name, storeId, quantity, price, image, buyingPrice, hashVaraients, savedItemId, product
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decode(String.self, forKey: .productId)
        name = try container.decode(String.self, forKey: .name)
        storeId = try container.decodeIfPresent(String.self, forKey: .storeId) ?? ""
        quantity = try container.decode(Int.self, forKey: .quantity)
        price = try container.decode(Int.self, forKey: .price)
        image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        buyingPrice = try container.decode(Int.self, forKey: .buyingPrice)
        hashVaraients = try container.decodeIfPresent([String:String].self, forKey: .hashVaraients) ?? [String:String]()
        savedItemId = try container.decodeIfPresent(String.self, forKey: .savedItemId) ?? ""
        product = try container.decodeIfPresent(StoreProduct.self, forKey: .product)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(productId, forKey: .productId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(storeId, forKey: .storeId)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encode(buyingPrice, forKey: .buyingPrice)
        try container.encodeIfPresent(hashVaraients, forKey: .hashVaraients)
        try container.encodeIfPresent(savedItemId, forKey: .savedItemId)
        try container.encodeIfPresent(product, forKey: .product)
    }
}

extension OrderProductObject {
    static func example() -> OrderProductObject {
        var obj =  OrderProductObject()
        obj.name = "Wegz Tshirt"
        obj.quantity = 1
        obj.price = 400
        obj.image = "https://content-management-files.canva.com/cdn-cgi/image/f=auto,q=70/2fdbd7ab-f378-4c63-8b21-c944ad2633fd/header_t-shirts2.jpg"
        obj.buyingPrice = 100
        obj.hashVaraients = ["Color": "Black", "Size": "Large"]
        return obj
    }
    
    func isEqual(_ other: OrderProductObject) -> Bool {
        // Compare properties to determine if two objects are equal
        return self.productId == other.productId && self.hashVaraients == other.hashVaraients
    }
}

