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
    
    @Published var selectedCategory:Category? {
        didSet {
            Task { await updateProducts() }
        }
    }
    
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
    
    func updateProducts() async {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        print("Getting products")
        
        DispatchQueue.main.async {
            self.isLoadingCategory = true
        }
        
        do {
            let newProducts = try await ProductsDao(storeId: storeId).getByCategory(id: selectedCategory?.id ?? "")
            
            DispatchQueue.main.async {
                self.products.removeAll()
                self.products = newProducts
                self.updateListIndexs()
                self.isLoadingCategory = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            CrashsManager().addLogs(error.localizedDescription, "AddToCart")
        }
    }
    
    func getCategories() async {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        DispatchQueue.main.async { self.isLoading = true }
        
        do {
            let category = try await CategoryDao(storeId: storeId).getAll()
            DispatchQueue.main.async {
                self.categories = category
                self.categories.append(Category(id: "", name: "Without", url: UserInformation.shared.user?.store?.logo ?? ""))
                self.isLoading = false
                self.selectFirstCategory()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            CrashsManager().addLogs(error.localizedDescription, "AddToCart")
        }
    }
    
    func selectFirstCategory() {
        guard !categories.isEmpty else {
            print("No first category")
            return
        }
        
        guard let firstItem = categories.first else {
            print("No first category")
            return
        }
        
        selectedCategory = firstItem
    }
}

struct AddToCart: View {
    @StateObject var viewModel = AddToCartViewModel()
    @State private var selectedProduct:StoreProduct?
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(viewModel.categories) { category in
                        CategoryTab(category: category, selected: $viewModel.selectedCategory)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(height: 100)
            
            Spacer().frame(height: 8)
            
            ScrollView {
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
            }
            
            .overlay {
                if viewModel.isLoadingCategory {
                    ProgressView()
                }
            }
            
            Spacer()
        }
        .padding()
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.updateProducts()
        }
        .searchable(text: $viewModel.searchText, prompt: Text("Search \(viewModel.products.count) Products"))
        .background(Color.background)
        .willLoad(loading: viewModel.isLoading)
        .overlay {
            if !viewModel.isLoading, viewModel.products.isEmpty {
                EmptyMessageViewWithButton(systemName: "cart.fill.badge.plus", msg: "No Products in this category, add a new product") {
                    VStack {
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
        .sheet(item: $selectedProduct, content: { product in
            ProductBuyingSheet(product: .constant(product), onAddedToCard: { product, options in
                CartManager().addItem(product: product, options: product.getVariantInfo(options))
                viewModel.getCart()
            })
        })
        .withAccessLevel(accessKey: .orderAdd, presentation: presentationMode)
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
