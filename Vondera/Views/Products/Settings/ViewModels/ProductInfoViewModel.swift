//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine
import SwiftUI

class ProductInfoViewModel : ObservableObject {
    @Published var product:StoreProduct
    var categorysDao:CategoryDao
    var productsDao:ProductsDao
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    
    
    @Published var name = ""
    @Published var desc = ""
    @Published var alwaysStocked = false

    // --> Selecting Category Vars
    @Published var categories = [Category]()
    @Published var category:Category?
    @Published var isSheetPresented = false
    
    @Published var isSaving = false
    @Published var isLoading = false
    @Published var msg:String?
    
    init(product:StoreProduct) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)
        self.categorysDao = CategoryDao(storeId: product.storeId)
        
        // --> Set the published values
        Task {
            await getStoreCategories()
            getData()
        }
    }
    
    func getStoreCategories() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let categories = try await categorysDao.getAll()
            DispatchQueue.main.async {
                self.categories = categories
                self.category = categories.first
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getData() {
        DispatchQueue.main.async { [self] in
            name = product.name
            desc = product.desc ?? ""
            alwaysStocked = product.alwaysStocked ?? true
            if let productCategory = getCategory() {
                category = productCategory
            }
        }
    }
    
    func getCategory() -> Category? {
        for cat in categories {
            if cat.id == product.categoryId {
                return cat
            }
        }
        
        return categories.first
    }
    
    func update() async {
        guard !name.isBlank else {
            showTosat(msg: "Fill the product name")
            return
        }
        
        guard category != nil else {
            showTosat(msg: "Please select a cateogry")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["name": name,
                                    "desc": desc,
                                    "alwaysStocked": alwaysStocked,
                                    "categoryId": category!.id,
                                    "categoryName": category!.name]
            
            try await productsDao.update(id: product.id, hashMap: map)
            
            
            showTosat(msg: "Store Main info changed")
            DispatchQueue.main.async {
                self.shouldDismissView = true
            }
        } catch {
            showTosat(msg: error.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
    }
    
    func showTosat(msg: String) {
        self.msg = msg
    }
}
