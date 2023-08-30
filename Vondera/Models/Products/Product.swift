import Foundation
import FirebaseFirestore

struct Product: Codable, Identifiable, Equatable, Hashable {
    var name: String = ""
    var id: String = ""
    var desc: String? = ""
    var quantity: Int = 0
    var addedBy: String? = ""
    var collectionId: String? = ""
    var price: Double = 0
    var buyingPrice: Double = 0
    var sold: Int? = 0
    var lastOrderDate: Timestamp?
    var createDate:Timestamp? = Timestamp(date: Date())
    var hashVarients: [[String: [String]]]? = []
    var visible: Bool? = true
    var alwaysStocked: Bool? = false
    var storeId: String = ""
    var listPhotos: [String] = []
    var listOrder: [ProductOrderObject]? = []
    var categoryId: String? = ""
    var categoryName: String? = ""
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    
    init() {}
    
    init(name: String, id: String, quantity: Int, addedBy: String, price: Double, buyingPrice: Double) {
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
    
    enum CodingKeys: String, CodingKey {
        case name, id, desc, quantity, addedBy, collectionId, price, buyingPrice, sold, lastOrderDate, createDate, hashVarients, visible, alwaysStocked, storeId, listPhotos, listOrder, categoryId, categoryName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(String.self, forKey: .id)
        desc = try container.decodeIfPresent(String.self, forKey: .desc)
        quantity = try container.decode(Int.self, forKey: .quantity)
        addedBy = try container.decodeIfPresent(String.self, forKey: .addedBy)
        collectionId = try container.decodeIfPresent(String.self, forKey: .collectionId)
        price = try container.decode(Double.self, forKey: .price)
        buyingPrice = try container.decode(Double.self, forKey: .buyingPrice)
        sold = try container.decodeIfPresent(Int.self, forKey: .sold)
        lastOrderDate = try container.decodeIfPresent(Timestamp.self, forKey: .lastOrderDate)
        createDate = try container.decodeIfPresent(Timestamp.self, forKey: .createDate)
        hashVarients = try container.decodeIfPresent([[String: [String]]].self, forKey: .hashVarients)
        visible = try container.decodeIfPresent(Bool.self, forKey: .visible)
        alwaysStocked = try container.decodeIfPresent(Bool.self, forKey: .alwaysStocked)
        storeId = try container.decode(String.self, forKey: .storeId)
        listPhotos = try container.decode([String].self, forKey: .listPhotos)
        listOrder = try container.decodeIfPresent([ProductOrderObject].self, forKey: .listOrder)
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        categoryName = try container.decodeIfPresent(String.self, forKey: .categoryName)
    }
    
    func defualtPhoto() -> String {
        self.listPhotos[0]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(desc, forKey: .desc)
        try container.encode(quantity, forKey: .quantity)
        try container.encodeIfPresent(addedBy, forKey: .addedBy)
        try container.encodeIfPresent(collectionId, forKey: .collectionId)
        try container.encode(price, forKey: .price)
        try container.encode(buyingPrice, forKey: .buyingPrice)
        try container.encodeIfPresent(sold, forKey: .sold)
        try container.encodeIfPresent(lastOrderDate, forKey: .lastOrderDate)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encode(hashVarients, forKey: .hashVarients)
        try container.encodeIfPresent(visible, forKey: .visible)
        try container.encodeIfPresent(alwaysStocked, forKey: .alwaysStocked)
        try container.encode(storeId, forKey: .storeId)
        try container.encode(listPhotos, forKey: .listPhotos)
        try container.encodeIfPresent(listOrder, forKey: .listOrder)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(categoryName, forKey: .categoryName)
    }
    
    static func ==(lhs: Product, rhs: Product) -> Bool {
            return lhs.id == rhs.id
        }
}

extension Product {
    func filter(_ searchText:String) -> Bool {
        return self.name.localizedCaseInsensitiveContains(searchText) ||
        self.desc?.localizedCaseInsensitiveContains(searchText) ?? false
    }
    
    func mapToOrderProduct(q:Int = 1, varient:[String: String], savedId:String) -> OrderProductObject {
        return OrderProductObject(productId: self.id, name: self.name, storeId: self.storeId, quantity: q, price: self.price, image: self.listPhotos[0], buyingPrice: self.buyingPrice, hashVaraients: varient, savedItemId: savedId, product: self)
    }
    
    static func listExample() -> [Product] {
        var prods = [Product]()
        for _ in 1...10 {
            prods.append(Product.example())
        }
        
        return prods
    }
    
    static func example() -> Product {
        var prod = Product(name: "Wegz Tshirt", id: "1234", quantity: 40, addedBy: "", price: 400, buyingPrice: 50)
        prod.hashVarients = [["Color": ["Black", "White", "Gray"]], ["Size": ["Large", "Small"]]]
        prod.sold = 100
        prod.categoryName = "Tshirts"
        prod.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        prod.listPhotos = ["https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/61/805162/1.jpg?1359", "https://cdn.shopify.com/s/files/1/0441/7378/7294/files/TEE55_394x.jpg?v=1683365748"]
        
        return prod
    }
}
