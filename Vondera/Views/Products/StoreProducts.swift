//
//  StoreProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023
//

import SwiftUI
import FirebaseFirestore

class StoreProductsViewModel : ObservableObject {
    var storeId:String
    
    @Published var selectedCategory:Category? {
        didSet {
            updateDisplayedSub()
        }
    }
    
    @Published var selectedSubCategoryIndex = 0
    
    @Published var categories = [Category]()
    @Published var subCategories = [SubCategory]()
    @Published var displayedSubCategories = [SubCategory]()
    @Published var isLoading = false
    
    init(storeId:String) {
        self.storeId = storeId
        
        Task {
            await fetchData()
        }
    }
    
    func updateDisplayedSub() {
        guard let id = selectedCategory?.id else { return }
        var categoryItems = subCategories.filter { $0.categoryId == id }
        categoryItems.sort { $0.sortValue < $1.sortValue }
        
        categoryItems.insert(SubCategory(name: "All", id: ""), at: 0)
        DispatchQueue.main.async {
            self.selectedSubCategoryIndex = 0
            self.displayedSubCategories = categoryItems
        }
    }
    
    
    func fetchData() async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let categories = try await CategoryDao(storeId: storeId).getAll()
            let subCategories = try await SubStoreCategoryDao(storeId: storeId).getAll()
            
            DispatchQueue.main.async {
                self.categories = categories
                self.subCategories = subCategories
                self.categories.append(Category(id: "", name: "Without", url: UserInformation.shared.user?.store?.logo ?? ""))
                
                if !categories.isEmpty {
                    self.selectedCategory = self.categories.first
                }
                
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

struct StoreProducts: View {
    var storeId:String
    var isBuing:Bool = false
    
    @StateObject var viewModel:StoreProductsViewModel
    @State var cartItems = CartManager().getCart()
    
    init(storeId: String) {
        self.storeId = storeId
        self._viewModel = StateObject(wrappedValue: StoreProductsViewModel(storeId: storeId))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(viewModel.categories) { category in
                        CategoryTab(category: category, selected: $viewModel.selectedCategory)
                    }
                }
            }
            .frame(height: 100)
            
            CustomTopTabBar(tabIndex: $viewModel.selectedSubCategoryIndex, titles: viewModel.displayedSubCategories.map { $0.name.localize() })
                .padding(.leading, 12)
                .padding(.top, 12)
            
            Spacer().frame(height: 8)
            
            if !viewModel.displayedSubCategories.isEmpty {
                getProductsView()
            }
            
            
            Spacer()
        }
        .padding()
        .scrollIndicators(.hidden)
        .background(Color.background)
        .willLoad(loading: viewModel.isLoading)
        .navigationTitle("Products")
        .toolbar {
            if isBuing {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Cart()) {
                        CartBadgeView(cartItems: $cartItems)
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ProductsSearchView()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .onAppear {
            self.cartItems = CartManager().getCart()
        }
    }
    
    @ViewBuilder
    func getProductsView() -> some View {
        SubCategoryProducts(storeId: storeId,
                            categoryId: viewModel.selectedCategory?.id ?? "",
                            subCategoryId: getSubCategoryId(),
                            isBuying: isBuing)
        .id("\(viewModel.selectedCategory?.id ?? "")-\(getSubCategoryId())")
    }
    
    func getSubCategoryId() -> String {
        if (viewModel.displayedSubCategories.count - 1) < viewModel.selectedSubCategoryIndex { return "" }
        return viewModel.displayedSubCategories[viewModel.selectedSubCategoryIndex].id
    }
}

struct SubCategoryProducts: View {
    var storeId: String
    var categoryId: String
    var subCategoryId: String
    var isBuying: Bool = false
    
    @State private var isFetching = false
    @State private var isLoading = false
    @State private var items = [StoreProduct]()
    
    @State private var lastDocument: DocumentSnapshot?
    @State private var hasMore = true
    
    var body: some View {
        ScrollView {
            VStack {
                HStack { Spacer() }
                if !items.isEmpty, !isLoading {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(items.indices, id: \.self) { index in
                            if items.indices.contains(index) {
                                VStack {
                                    NavigationLink(destination: ProductDetails(product: $items[index])) {
                                        ProductCard(product: $items[index])
                                            .id(UUID().uuidString)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if items[index].id == items.last?.id && hasMore {
                                        ProgressView()
                                            .onAppear {
                                                Task { await fetchProducts() }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .task { await fetchProducts() }
        .refreshable { await reset() }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .withEmptyView(text: "No products in this category", count: items.count, loading: isLoading)
    }
    
    func reset() async {
        // Use main thread for clearing items and resetting flags
        await MainActor.run {
            isLoading = false
            isFetching = false
            items.removeAll()
            lastDocument = nil
            hasMore = true
            print("Reset")
        }
        
        await fetchProducts()
    }
    
    func fetchProducts() async {
        guard hasMore, !isLoading, !isFetching else { return }
        
        await MainActor.run {
            isLoading = (lastDocument == nil)
            isFetching = (lastDocument != nil)
        }
        
        print("Fetching ...")
        
        do {
            let result = try await ProductsDao(storeId: storeId).getBySubcategory(
                categoryId: categoryId, subCategoryId: subCategoryId, lastDoc: lastDocument
            )
            
            print("Result fetched ...")
            
            await MainActor.run {
                // Append new items on the main thread
                self.items.append(contentsOf: result.0)
                self.hasMore = !result.0.isEmpty
                self.lastDocument = result.1
                self.isLoading = false
                self.isFetching = false
                print("Items updated, flags toggled")
            }
        } catch {
            print("Error in fetching \(error)")
            await MainActor.run {
                self.isLoading = false
                self.isFetching = false
            }
        }
    }
}
