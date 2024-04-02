import Foundation
import FirebaseFirestore

struct StoreProduct: Codable, Identifiable, Equatable, Hashable {
    var name: String = ""
    var id: String = ""
    var desc: String? = ""
    var quantity: Int = 0
    var addedBy: String? = ""
    var collectionId: String? = ""
    var price: Int = 0
    var buyingPrice: Int = 0
    var sold: Int? = 0
    var lastOrderDate: Timestamp?
    var createDate:Timestamp? = Timestamp(date: Date())
    var hashVarients: [[String: [String]]]?
    
    var visible: Bool? = true
    var alwaysStocked: Bool? = false
    var storeId: String = ""
    var listPhotos: [String] = []
    var listOrder: [ProductOrderObject]? = []
    var categoryId: String? = ""
    var categoryName: String? = ""
    
    var crossedPrice:Double? = 0
    var featured:Bool? = false
    var views:Int? = 0
    
    var totalReviews:Double? = 0;
    var avgRating:Float? = 0;
    var totalRating:Double? = 0;
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
    
    init() {}
    
    init(name: String, id: String, quantity: Int, addedBy: String, price: Int, buyingPrice: Int) {
        self.name = name
        self.id = id
        self.quantity = quantity
        self.addedBy = addedBy
        self.price = price
        self.buyingPrice = buyingPrice
    }
    
    var realSold: Int {
        var sold = 0
        for order in listOrder ?? [ProductOrderObject]() {
            sold += order.quantity
        }
        return sold
    }
 
    func getProfit() -> Int {
        return Int(price - buyingPrice)
    }
    
    func getMargin() -> String {
        if buyingPrice == 0 {
            return "100.0"
        }
        
        let margin =  ((price - buyingPrice) / price) * 100
        return String(format: "%.1f", margin)
    }
    
    func getMinQuantity() -> Int {
        if alwaysStocked ?? false {
            return 1000
        }
        
        if quantity < 1 {
            return 1
        }
        
        return quantity
    }
    
    
    func getProductLink(baseLink:String) -> URL {
        return URL(string: "\(baseLink)/product/\(id)")!
    }
    
    func defualtPhoto() -> String {
        self.listPhotos[0]
    }
    
    
    static func ==(lhs: StoreProduct, rhs: StoreProduct) -> Bool {
            return lhs.id == rhs.id
        }
}

extension StoreProduct {
    func filter(_ searchText:String) -> Bool {
        if searchText.isBlank {
            return true
        }
        
        return self.name.localizedCaseInsensitiveContains(searchText) ||
        self.desc?.localizedCaseInsensitiveContains(searchText) ?? false
    }
    
    func mapToOrderProduct(q:Int = 1, varient:[String: String]) -> OrderProductObject {
        return mapToOrderProduct(q:q, varient: varient, savedId: CartManager.generatePIN())
    }
    func mapToOrderProduct(q:Int = 1, varient:[String: String], savedId:String) -> OrderProductObject {
        return OrderProductObject(productId: self.id, name: self.name, storeId: self.storeId, quantity: q, price: self.price, image: self.listPhotos[0], buyingPrice: self.buyingPrice, hashVaraients: varient, savedItemId: savedId, product: self)
    }
    
    static func listExample() -> [StoreProduct] {
        var prods = [StoreProduct]()
        for _ in 1...10 {
            prods.append(StoreProduct.example())
        }
        
        return prods
    }
    
    static func example() -> StoreProduct {
        var prod = StoreProduct(name: "Wegz Tshirt", id: "1234", quantity: 40, addedBy: "", price: 400, buyingPrice: 50)
        prod.hashVarients = [["Color": ["Black", "White", "Gray"]], ["Size": ["Large", "Small"]]]
        prod.sold = 100
        prod.crossedPrice = 500
        prod.categoryName = "Tshirts"
        prod.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        prod.listPhotos = ["https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/61/805162/1.jpg?1359", "https://cdn.shopify.com/s/files/1/0441/7378/7294/files/TEE55_394x.jpg?v=1683365748"]
        
        return prod
    }
}
