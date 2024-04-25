//
//  AddProductViewMode.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import Firebase
import FirebaseStorage
import Combine

class AddProductViewModel : ObservableObject {
    var storeId:String = ""
    var categorysDao:CategoryDao
    var productsDao:ProductsDao
    
    var productId = ""
    @Published var page = 1
    @Published var categories = [Category]()
    
    @Published var recentProducts = [StoreProduct]()
    @Published var selectedTemplate:StoreProduct?
    
    
    @Published var selectedCategory:Category? {
        didSet {
            Task {
                await updateRecentProducts()
            }
        }
    }
    
    @Published var isSheetPresented = false
    
    @Published var selectedPhotos: [UIImage] = []
    
    @Published var name = ""
    @Published var desc = ""
    
    @Published var alwaysStocked = false
    @Published var sellingPrice = "0"
    @Published var cost = "0"
    @Published var crossed = "0"
    @Published var quantity = "0"
    @Published var isSaving = false
    
    @Published var listVarients = [[String:[String]]]()
    @Published var listTitles = [String]()
    @Published var listOptions = [[String]]()
    
    @Published var templateVariantDetails = [VariantsDetails]()
    
    var myUser = UserInformation.shared.getUser()
    
    @Published var msg:String?
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    init(storeId: String) {
        self.storeId = storeId
        self.categorysDao = CategoryDao(storeId: storeId)
        self.productsDao = ProductsDao(storeId: storeId)
        self.myUser = UserInformation.shared.getUser()
        
        Task {
            await createProductId()
            await getStoreCategories()
        }
    }
    
    
    
    func deleteVarient(i:Int) {
        listTitles.remove(at: i)
        listOptions.remove(at: i)
        listVarients.remove(at: i)
    }
    
    func canAddVarient() -> Bool {
        if listVarients.isEmpty { return true }
        if listTitles.last!.isEmpty || listOptions.last!.isEmpty {
            return false
        }
        
        return true
    }
    
    func addVarient() {
        guard canAddVarient() else {
            showMessage("Fill the current varient first")
            return
        }
        
        listVarients.append(["":[]])
        listTitles.append("")
        listOptions.append([String]())
    }
    
    func showMessage(_ msg:String) {
        self.msg = msg
    }
    
    func nextPage() {
        if page == 1 {
            if (check1()) {page = 2}
        } else if page == 2 {
            if (check2()) {
                if alwaysStocked {
                    uploadPhotos()
                } else {
                    page = 3
                }
            }
        } else if page == 3 {
            if(check3()) { uploadPhotos() }
        }
    }
    
    func showPrevPage() {
        if page == 1 {
            shouldDismissView = true
            return
        }
        
        page -= 1
    }
    
    func check1() -> Bool {
        guard !name.isBlank else {
            showMessage("Enter product name")
            return false
        }
        
        guard selectedPhotos.count > 0 else {
            showMessage("Select one photo at least")
            return false
        }
        
        guard selectedCategory != nil else {
            showMessage("Select the product category")
            return false
        }
        
        guard sellingPrice.isNumeric else {
            showMessage("Enter a valid price amount")
            return false
        }
        
        guard sellingPrice != "0" else {
            showMessage("Selling price can't be Zero LE")
            return false
        }
        
        guard cost.isNumeric else {
            showMessage("Enter a valid cost amount")
            return false
        }
        
        return true
    }
    
    func check2() -> Bool {
        var titleFilled = true
        var optionsProvided = true
        
        for str in listTitles {
            if str.isBlank {titleFilled = false}
        }
        
        for list in listOptions {
            if list.count < 2 {optionsProvided = false}
        }
        
        guard titleFilled else {
            showMessage("Fill all varients titles")
            return false
        }
        
        guard optionsProvided else {
            showMessage("Add at least 2 options to each varient")
            return false
        }
        
        return true
    }
    
    func check3() -> Bool {
        guard quantity.isNumeric else {
            showMessage("Enter a valid quantity amount")
            return false
        }
        
        return true
    }
    
    func listVarient() -> [[String: [String]]] {
        var listVars = [[String: [String]]]()
        for (index, title) in listTitles.enumerated() {
            listVars.append([title:listOptions[index]])
        }
        
        return listVars
    }
    
    func uploadPhotos() {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        if let storeId = myUser?.storeId {
            FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: selectedPhotos, storageRef: "stores/\(storeId)/products/\(productId)") { imageURLs, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.showMessage(error.localizedDescription)
                    }
                } else if let imageURLs = imageURLs {
                    self.saveProduct(uris: imageURLs)
                }
            }
        }
    }
    
    func updateRecentProducts() async {
        DispatchQueue.main.async {
            self.selectedTemplate = nil
            self.recentProducts.removeAll()
        }
        
        if let id = selectedCategory?.id {
            if let templetes = try? await ProductsDao(storeId: storeId).getCategoryRecent(categoryId: id) {
                DispatchQueue.main.async {
                    self.recentProducts = templetes
                }
            }
        }
    }
    
    func chooseTemplete(product:StoreProduct) {
        self.selectedTemplate = product
        self.desc = product.desc ?? ""
        self.cost = "\(Int(product.buyingPrice))"
        self.crossed = "\(Int(product.crossedPrice ?? 0))"
        self.sellingPrice = "\(Int(product.price))"
        self.alwaysStocked = product.alwaysStocked ?? false
        self.quantity = "\(product.quantity)"
        self.templateVariantDetails = product.getVariant()
        
        self.listVarients = product.hashVarients ?? []
        self.listTitles = product.hashVarients?.getTitles() ?? []
        self.listOptions = product.hashVarients?.getOptions() ?? []
        
        self.msg = "Product data filled"
    }
    
    func saveProduct(uris: [String]) {
        Task {
            // MARK : Create a product Object
            var product = StoreProduct(name: name.lowercased(), id: productId, quantity: Int(quantity) ?? 0, addedBy: "", price: Double(sellingPrice) ?? 0, buyingPrice: Double(cost) ?? 0)
            
            product.desc = desc
            product.storeId = storeId
            product.crossedPrice = Double(crossed) ?? 0
            product.listPhotos = uris
            product.hashVarients = listVarient()
            product.alwaysStocked = alwaysStocked
            product.categoryId = selectedCategory?.id ?? ""
            product.categoryName = selectedCategory?.name ?? ""
            
            product.variantsDetails = listVarient().isEmpty ? [] : templateVariantDetails.map { detail in
                var modifiedDetail = detail // Create a copy of the detail
                modifiedDetail.image = ""
                modifiedDetail.optimizedImage = ""
                modifiedDetail.cost = Double(cost) ?? 0
                modifiedDetail.price = Double(sellingPrice) ?? 0
                return modifiedDetail
            }
            
            // MARK : Save the product to database
            do {
                try await productsDao.create(product)
                showMessage("Product has been added")
                
                // --> Saving Local
                if let myUser = UserInformation.shared.getUser() {
                    if var productsCount = myUser.store?.productsCount {
                        productsCount = productsCount + 1
                        myUser.store?.productsCount = productsCount
                        UserInformation.shared.updateUser(myUser)
                    }
                }
                
                DispatchQueue.main.async {
                    self.shouldDismissView = true
                }
            } catch {
                showMessage(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.isSaving = false
            }
        }
    }
    
    func getStoreCategories() async {
        do {
            categories = try await categorysDao.getAll()
            if let cat = categories.first {
                selectedCategory = cat
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func removePhoto(image: UIImage) {
        if let index = selectedPhotos.firstIndex(of: image) {
            selectedPhotos.remove(at: index)
        }
    }
    
    // Add a function to clear the selected photos
    func clearSelectedPhotos() {
        selectedPhotos.removeAll()
    }
    
    func createProductId() async {
        let id:String = "\(generateRandomNumber())"
        let isExist = try? await productsDao.productExist(id: id)
        if (isExist ?? true) {
            await createProductId()
            return
        }
        
        self.productId = id
    }
    
    func generateRandomNumber() -> Int {
        let randomNumber = arc4random_uniform(9000) + 1000
        return Int(randomNumber)
    }
}
