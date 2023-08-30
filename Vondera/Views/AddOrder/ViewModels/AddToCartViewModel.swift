//
//  AddToCartViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation

class AddToCartViewModel : ObservableObject {
    var storeId:String
    var categoryDao:CategoryDao
    var productsDao:ProductsDao
    
    @Published var cartItems = [SavedItems]()
    @Published var categories = [Category]()
    @Published var products = [Product]()
    @Published var selectedCategory:String = ""
    @Published var errorMsg = ""
    @Published var isLoading = false
    @Published var searchText = ""
    
    var filteredItems: [Product] {
        guard !searchText.isEmpty else { return products }
        return products.filter { product in
            product.filter(searchText)
        }
    }
    
    init(storeId:String) {
        self.storeId = storeId
        self.categoryDao = CategoryDao(storeId: storeId)
        self.productsDao = ProductsDao(storeId: storeId)
        
        Task {
            await getCategories()
            await getCart()
        }
    }
    
    func addProduct(_ prod:SavedItems) async {
        await CartManager().addItem(savedItems: prod)
        await getCart()
    }
    
    func getCart() async {
        cartItems = await CartManager().getCart()
    }
    
    func selectCategory(id:String) async {
        self.isLoading = true
        self.selectedCategory = id
        do {
            self.products = try await productsDao.getByCategory(id: self.selectedCategory)
            self.isLoading = false
        } catch {
            showError(msg: error.localizedDescription)
        }
    }
    
    func getCategories() async {
        do {
            self.categories = try await categoryDao.getAll()
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
