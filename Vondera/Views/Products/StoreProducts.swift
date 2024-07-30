//
//  StoreProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023
//

import SwiftUI

class StoreProductsViewModel : ObservableObject {
    var storeId:String
    var categoryDao:CategoryDao
    var productsDao:ProductsDao
    
    @Published var sortIndex = "sold" {
        didSet {
            updateListIndexs()
        }
    }
    
    @Published var selectedCategory:Category? {
        didSet {
            Task { await updateProducts() }
        }
    }
    
    @Published var categories = [Category]()
    @Published var products = [StoreProduct]()
    
    
    @Published var errorMsg = ""
    @Published var isLoading = false
    @Published var isLoadingCategory = false
    @Published var searchText = ""
    
    init(storeId:String) {
        self.storeId = storeId
        self.categoryDao = CategoryDao(storeId: storeId)
        self.productsDao = ProductsDao(storeId: storeId)
        
        Task {
            await getCategories()
        }
    }
    
    func updateProducts() async {
        self.isLoadingCategory = true
        
        do {
            self.products = try await productsDao.getByCategory(id: self.selectedCategory?.id ?? "")
            DispatchQueue.main.async {
                self.updateListIndexs()
                self.isLoadingCategory = false
            }
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
            self.isLoading = true
            self.categories = try await categoryDao.getAll()
            self.categories.append(Category(id: "", name: "Without", url: UserInformation.shared.user?.store?.logo ?? ""))
            
            if !categories.isEmpty {
                DispatchQueue.main.async {
                    self.selectedCategory = self.categories.first
                    self.isLoading = false
                }
            }
        } catch {
            showError(msg: error.localizedDescription)
        }
    }
    
    private func showError(msg:String) {
        self.errorMsg = msg
    }
}

struct StoreProducts: View {
    var storeId:String
    @ObservedObject var viewModel:StoreProductsViewModel
    @State var myUser:UserData?
    
    init(storeId: String) {
        self.storeId = storeId
        self.viewModel =  StoreProductsViewModel(storeId: storeId)
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
            
            
            Spacer().frame(height: 8)


            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach($viewModel.products.indices, id: \.self) { index in
                        if $viewModel.products[index].wrappedValue.filter(viewModel.searchText) {
                            NavigationLink(destination: ProductDetails(product: $viewModel.products[index], onDelete: { item in
                                if let index = viewModel.products.firstIndex(where: {$0.id == item.id}) {
                                    DispatchQueue.main.async {
                                        viewModel.products.remove(at: index)
                                    }
                                }
                            })) {
                                ProductCard(product: $viewModel.products[index])
                                    .id(viewModel.products[index].id)
                            }
                            .buttonStyle(.plain)
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
            if viewModel.products.isEmpty {
                EmptyMessageViewWithButton(systemName: "cart.fill.badge.plus", msg: "You haven't added any products to your store yet !") {
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
            self.myUser = UserInformation.shared.getUser()
        }
        .navigationTitle("Products")
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
                NavigationLink("Add") {
                    AddProductView(storeId: storeId)
                }
            }
        }
    }
}

struct StoreProducts_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoreProducts(storeId: "lcvPuRAIVVUnRcZpttlPsRPLqoY2")
        }
    }
}
