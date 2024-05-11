//
//  AddToCart.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI

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
    @Published var isLoading = false
    @Published var isLoadingCategory = false
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
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        print("Getting products")
        
        DispatchQueue.main.async {
            self.isLoadingCategory = true
            self.selectedCategory = id
        }
        
        do {
            print("Selected category id \(id)")
            let newProducts = try await ProductsDao(storeId: storeId).getByCategory(id: id)
            print("Got \(newProducts.count)")
            DispatchQueue.main.async {
                self.products.removeAll()
                self.products = newProducts
                self.updateListIndexs()
                self.isLoadingCategory = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            CrashsManager().addLogs(error.localizedDescription, "AddToCart")
            print("\(error.localizedDescription)")
        }
    }
    
    func getCategories() async {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let category = try await CategoryDao(storeId: storeId).getAll()
            DispatchQueue.main.async {
                self.categories = category
                self.categories.append(Category(id: "", name: "Without", url: UserInformation.shared.user?.store?.logo ?? ""))
                self.isLoading = false
                print("Got the categories")
                self.selectFirstCategory()
            }
           
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            CrashsManager().addLogs(error.localizedDescription, "AddToCart")
        }
    }
    
    func selectFirstCategory() {
        print("Setting first category")
        
        guard !categories.isEmpty else {
            print("No first category")
            return
        }
        
        guard let firstItem = categories.first else {
            print("No first category")
            return
        }
        
        Task {
            await self.selectCategory(id: firstItem.id)
        }
    }
}

struct AddToCart: View {
    @StateObject var viewModel = AddToCartViewModel()
    @State private var selectedProduct:StoreProduct?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            content()
        }
        .refreshable {
            await viewModel.selectCategory(id: viewModel.selectedCategory)
        }
        .sheet(item: $selectedProduct, content: { product in
            ProductBuyingSheet(product: .constant(product), onAddedToCard: { product, options in
                CartManager().addItem(product: product, options: product.getVariantInfo(options))
                viewModel.getCart()
            })
        })
        .searchable(text: $viewModel.searchText, prompt: Text("Search \(viewModel.products.count) Products"))
        .background(Color.background)
        .willLoad(loading: viewModel.isLoading)
        .overlay {
            if !viewModel.isLoading, viewModel.products.isEmpty {
                EmptyMessageViewWithButton(systemName: "cart.fill.badge.plus", msg: "No Products in this category, add a new product") {
                    VStack {
                        if UserInformation.shared.user?.canAccessAdmin ?? false {
                            NavigationLink {
                                AddProductView()
                            } label: {
                                Text("Add Product")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.getCart()
        }
        .navigationTitle("Add to cart")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort Option", selection: $viewModel.sortIndex) {
                        Text("Name")
                            .tag("name")
                        
                        Text("Quantity")
                            .tag("quantity")
                        
                        Text("Most Selling")
                            .tag("sold")
                        
                        Text("Last Order Date")
                            .tag("lastOrderDate")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: Cart()) {
                    CartBadgeView(cartItems: $viewModel.cartItems)
                }
            }
        }
    }
    
    
    @ViewBuilder func content() -> some View {
        LazyVStack(alignment: .leading) {
            LazyHStack(alignment: .center) {
                ForEach(viewModel.categories) { category in
                    CategoryTab(category: category, onClick: {
                        Task {
                            await viewModel.selectCategory(id: category.id)
                        }
                    }, selected: Binding(
                        get: { viewModel.selectedCategory == category.id },
                        set: { isSelected in
                            if isSelected {
                                viewModel.selectedCategory = category.id
                            }
                        }
                    ))
                }
            }
            .padding()
            
            // MARK : Items
            if viewModel.isLoadingCategory {
                ProgressView()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(Array($viewModel.products.enumerated()), id: \.element.id) { i, product in
                        if product.wrappedValue.filter(viewModel.searchText) {
                            ProductCard(product: product, showBuyButton: false)
                                .id(product.id)
                                .onTapGesture {
                                    self.selectedProduct = $viewModel.products[i].wrappedValue
                                }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            
        }
    }
}

struct CartBadgeView: View {
    @Binding var cartItems: [SavedItems]
    
    var body: some View {
        ZStack {
            Image(systemName: "cart.fill")
                .font(.system(size: 20))
            
            Circle()
                .fill(Color.blue)
                .frame(width: 16, height: 16)
                .overlay(
                    Text("\(cartItems.count)")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                )
                .offset(x: 15, y: -15)
            
        }
    }
}
