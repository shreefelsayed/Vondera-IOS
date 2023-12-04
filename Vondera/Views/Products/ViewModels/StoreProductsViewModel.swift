//
//  StoreProductsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation

class StoreProductsViewModel : ObservableObject {
    var storeId:String
    var categoryDao:CategoryDao
    var productsDao:ProductsDao
    
    @Published var sortIndex = "sold" {
        didSet {
            updateListIndexs()
        }
    }
    
    @Published var categories = [Category]()
    @Published var products = [StoreProduct]()
    @Published var selectedCategory:String = ""
    @Published var errorMsg = ""
    @Published var isLoading = false
    @Published var searchText = ""
    
    init(storeId:String) {
        self.storeId = storeId
        self.categoryDao = CategoryDao(storeId: storeId)
        self.productsDao = ProductsDao(storeId: storeId)
        
        Task {
            await getCategories()
        }
    }
    
    func selectCategory(id:String) async {
        self.isLoading = true
        self.selectedCategory = id
        do {
            self.products = try await productsDao.getByCategory(id: self.selectedCategory)
            DispatchQueue.main.async {
                self.updateListIndexs()
            }
            self.isLoading = false
        } catch {
            showError(msg: error.localizedDescription)
        }
    }
    
    func updateListIndexs() {
        DispatchQueue.main.async { [self] in
            switch sortIndex {
            case "name":
                products.sort { $0.name < $1.name}
            case "quantity":
                products.sort { $0.quantity > $1.quantity}
            case "sold":
                products.sort { $0.sold ?? 0 > $1.sold ?? 0}
            case "lastOrderDate":
                products.sort { $0.lastOrderDate?.toDate() ?? Date() > $1.lastOrderDate?.toDate() ?? Date()}
            default:
                print("None known value")
            }
        }
        
    }
    
    func getCategories() async {
        do {
            self.categories = try await categoryDao.getAll()
            self.categories.append(Category(id: "", name: "Without", url: ""))
            
            if !categories.isEmpty {
                await selectCategory(id: categories[0].id)
            }
        } catch {
            showError(msg: error.localizedDescription)
        }
        
    }
    
    private func showError(msg:String) {
        self.errorMsg = msg
    }
}
