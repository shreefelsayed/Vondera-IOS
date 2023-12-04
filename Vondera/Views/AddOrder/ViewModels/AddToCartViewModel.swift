//
//  AddToCartViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation

class AddToCartViewModel : ObservableObject {
    @Published var sortIndex = "sold" {
        didSet {
            updateListIndexs()
        }
    }
    
    @Published var cartItems = [SavedItems]()
    @Published var categories = [Category]()
    @Published var products = [StoreProduct]()
    @Published var selectedCategory:String = ""
    @Published var errorMsg = ""
    @Published var isLoading = false
    @Published var searchText = ""
    
    init() {
        getCart()
        
        Task {
            await getCategories()
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
    
    func getCart() {
        cartItems = CartManager().getCart()
    }
    
    func selectCategory(id:String) async {
        self.isLoading = true
        self.selectedCategory = id
        do {
            if let storeId = UserInformation.shared.user?.storeId {
                let newProducts = try await ProductsDao(storeId: storeId).getByCategory(id: self.selectedCategory)
                
                DispatchQueue.main.async {
                    self.products.removeAll()
                    self.products = newProducts
                    self.updateListIndexs()
                    self.isLoading = false
                }
            }
            
            
        } catch {
            showError(msg: error.localizedDescription)
        }
    }
    
    func getCategories() async {
        do {
            if let storeId = UserInformation.shared.user?.storeId {
                let category = try await CategoryDao(storeId: storeId).getAll()
                DispatchQueue.main.async {
                    self.categories = category
                    self.categories.append(Category(id: "", name: "Without", url: ""))
                    if !self.categories.isEmpty {
                        Task {
                            await self.selectCategory(id: self.categories[0].id)
                        }
                    }
                }
            }
        } catch {
            showError(msg: error.localizedDescription)
        }
        
    }
    
    private func showError(msg:String) {
        DispatchQueue.main.async {
            self.errorMsg = msg
        }
    }
}
