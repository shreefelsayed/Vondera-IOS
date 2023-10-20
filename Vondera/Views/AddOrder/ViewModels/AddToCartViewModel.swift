//
//  AddToCartViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation

class AddToCartViewModel : ObservableObject {
    @Published var myUser:UserData?
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
    
    var filteredItems: [StoreProduct] {
        guard !searchText.isEmpty else { return products }
        return products.filter { product in
            product.filter(searchText)
        }
    }
    
    init() {
        Task {
            if let user = UserInformation.shared.getUser() {
                self.myUser = user
            }
            
            await getCategories()
            await getCart()
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
            self.products = try await ProductsDao(storeId: myUser?.storeId ?? "").getByCategory(id: self.selectedCategory)
            DispatchQueue.main.async {
                self.updateListIndexs()
            }
            self.isLoading = false
        } catch {
            showError(msg: error.localizedDescription)
        }
    }
    
    func getCategories() async {
        do {
            self.categories = try await CategoryDao(storeId: myUser?.storeId ?? "").getAll()
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
