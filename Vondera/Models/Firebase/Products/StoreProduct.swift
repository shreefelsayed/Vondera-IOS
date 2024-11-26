import Foundation
import FirebaseFirestore

struct StoreProduct: Codable, Identifiable, Equatable, Hashable {
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
    
    var hashVarients: [[String: [String]]]?
    var variantsDetails : [VariantsDetails]? = []

    var visible: Bool? = true
    var alwaysStocked: Bool? = false
    var storeId: String = ""
    var listPhotos: [String] = []
    var listOptamized: [String]? = []
    
    var listOrder: [ProductOrderObject]? = []
    var categoryId: String? = ""
    var categoryName: String? = ""
    
    var crossedPrice:Double? = 0
    var featured:Bool? = false
    var views:Int? = 0
    
    var totalReviews:Double? = 0;
    var avgRating:Float? = 0;
    var totalRating:Double? = 0;
    
    var subCategoryId:String? = ""
    var subCategoryName:String? = ""
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
        
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
    
    func getProductLink() -> URL? {
        if let link = UserInformation.shared.user?.store?.getStoreDomain(), (visible ?? true), let siteEnabled = UserInformation.shared.user?.store?.websiteEnabled, siteEnabled {
            if let url = URL(string: "\(link)/product/\(id)") {
                return url
            }
        }
        
        return nil
    }
    
    func defualtPhoto() -> String {
        if let optimizedList = listOptamized, !optimizedList.isEmpty {
            for item in optimizedList {
                if !item.isEmpty {
                    return item
                }
            }
        }
        
        if let firstPhoto = listPhotos.first, !firstPhoto.isEmpty {
            return firstPhoto
        }
        
        return ""
    }
    
    func getDisplayPhotos() -> [String] {
        // Create a result array with the same size as listPhotos
        var displayPhotos = [String](repeating: "", count: listPhotos.count)
        
        // Iterate over each index of listPhotos
        for index in listPhotos.indices {
            // Check if listOptamized has an item at this index and it is not empty
            if index < listOptamized?.count ?? 0, let optimizedItem = listOptamized?[index], !optimizedItem.isEmpty {
                // Use the item from listOptamized
                displayPhotos[index] = optimizedItem
            } else {
                // Otherwise, use the item from listPhotos
                displayPhotos[index] = listPhotos[index]
            }
        }
        
        return displayPhotos
    }
    
    // MARK : This migrates all the varients
    func getVariant() -> [VariantsDetails] {
        var varientDetails = [VariantsDetails]()
        
        guard let varients = hashVarients, !varients.isEmpty else { return varientDetails }
        let newOptions = varients.mapVariantDetails(q: 0, cost: buyingPrice, price: price)
        
        // --> We need to get the items from the product
        if let currentOptions = variantsDetails {
            for (_, option) in newOptions.enumerated() {
                if let existOption = currentOptions.getVarientFromOption(option.options) {
                    varientDetails.append(existOption)
                } else {
                    varientDetails.append(option)
                }
            }
            
        } else {
            varientDetails = newOptions
        }
        
        return varientDetails
    }

    // MARK : This gets the variant from the option
    func getVariantInfo(_ option:[String:String]) -> VariantsDetails? {
        if let option = getVariant().getVarientFromOption(option) {
            return option
        }
        
        return nil
    }
    
    // MARK : This checks if the product has a variant
    func hasVariants() -> Bool {
        return !getVariant().isEmpty
    }
    
    func getQuantity() -> Int {
        if alwaysStocked ?? false {
            return 0
        }
        
        if hasVariants() {
            return getVariant().totalQuantity()
        }
        
        return quantity
    }
    
    func getMaxQuantity(variant:VariantsDetails?) -> Int {
        if alwaysStocked ?? false {
            return 1000
        }
        
        if let variant = variant, getVariantInfo(variant.options) != nil {
            return variant.quantity
        }
        
        return self.quantity
    }
    
    func canAddToCart(variant:VariantsDetails?) -> Bool {
       return getMaxQuantity(variant: variant) > 0
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
        let variant = self.getVariantInfo(varient)
        var image = defualtPhoto()
        if let variant = variant, !variant.getPhoto().isBlank {
            image = variant.getPhoto()
        }
        return OrderProductObject(productId: self.id, name: self.name, storeId: self.storeId, quantity: q, price: variant?.price ?? self.price, image: image, buyingPrice: variant?.cost ?? self.buyingPrice, hashVaraients: varient, savedItemId: savedId, product: self)
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

struct VariantsDetails: Codable, Equatable, Hashable {
    var options: [String: String]
    var quantity: Int
    var sold:Int?
    var image: String
    var optimizedImage:String? = ""
    var cost: Double
    var price: Double
    
    func formatOptions() -> String {
        return options.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
    
    func getPhoto() -> String {
        guard let optimizedImage = optimizedImage else {
            return image
        }
        
        return optimizedImage.isBlank ? image : optimizedImage
    }
}

