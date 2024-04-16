//
//  ProductsFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import SwiftUI

class ProductsFragmentViewModel : ObservableObject {
    @Published var isLoading = true
    
    @Published var itemsTopSelling = [StoreProduct]()
    @Published var itemsMostViewed = [StoreProduct]()
    @Published var itemsLastOrdered = [StoreProduct]()
    
    @Published var siteReports = [StoreStatics]()
    @Published var staticsDays = 7 {
        didSet {
            Task {
                await getStatics()
            }
        }
    }
    
    init() {
        self.isLoading = true
        Task {
            await getContent()
        }
    }
    
    func getContent() async {
        if let storeId = UserInformation.shared.getUser()?.storeId {
            do {
                let mostSelling = try await ProductsDao(storeId: storeId).getTopSelling()
                let mostViewed = try await ProductsDao(storeId: storeId).getMostVieweed()
                let lastOrdered = try await ProductsDao(storeId: storeId).getLastOrdered()
                await getStatics()
                
                DispatchQueue.main.async {
                    self.itemsTopSelling = mostSelling
                    self.itemsMostViewed = mostViewed
                    self.itemsLastOrdered = lastOrdered
                    self.isLoading = false
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getStatics() async {
        do {
            if let storeId = UserInformation.shared.user?.storeId {
                let items = try await StaticsDao(storeId: storeId).getLastDays(days: staticsDays)
                DispatchQueue.main.async {
                    self.siteReports = items
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ProductsFragment: View {
    @StateObject var vm = ProductsFragmentViewModel()
    
    var body: some View {
        VStack {
            if let user = UserInformation.shared.getUser() {
                //TOOLBAR
                HStack {
                    Text("Products")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        if user.canAccessAdmin {
                            Menu {
                                NavigationLink(destination: AddProductView(storeId: user.storeId)) {
                                    Label("New Product", systemImage: "tag.fill")
                                }
                                
                                NavigationLink(destination: CreateCategory(storeId: user.storeId, onAdded: nil)) {
                                    Label("New Category", systemImage: "plus")
                                }
                            } label: {
                                Image(systemName: "plus.app")
                            }
                        }
                        
                        NavigationLink(destination: ProductsSearchView()) {
                            Image(systemName: "magnifyingglass.circle.fill")
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.title)
                    .bold()
                    
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                if let count = user.store?.productsCount, count <= 0 {
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
                } else {
                    List {
                        // MARK : 3 Cards with counters
                        Section {
                            NavigationLink(destination: StoreProducts(storeId: user.storeId)) {
                                HStack {
                                    Label(
                                        title: { Text("All Products").bold() },
                                        icon: { Image(.btnProducts) }
                                    )
                                    
                                    Spacer()
                                    
                                    Text("\(user.store?.productsCount ?? 0)")
                                }
                                
                                
                            }
                            
                            if user.canAccessAdmin {
                                NavigationLink(destination: StoreCategories(store: user.store!)) {
                                    HStack {
                                        Label(
                                            title: { Text("Categories").bold() },
                                            icon: { Image(.btnCollections) }
                                        )
                                        Spacer()
                                        
                                        Text("\(user.store?.categoriesCount ?? 0)")
                                    }
                                }
                                
                                
                                NavigationLink {
                                    WarehouseView(storeId: user.storeId)
                                } label: {
                                    Label(
                                        title: { Text("Warehouse").bold() },
                                        icon: { Image(.btnWarehouse) }
                                    )
                                }
                            }
                        }
                        
                        // MARK : Top Selling
                        if !vm.itemsTopSelling.isEmpty {
                            Section("Most Selling Products") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach($vm.itemsTopSelling.indices, id: \.self) { index in
                                            NavigationLink {
                                                ProductDetails(product: $vm.itemsTopSelling[index]) { item in
                                                    if let index = vm.itemsTopSelling.firstIndex(where: {$0.id == item.id}) {
                                                        vm.itemsTopSelling.remove(at: index)
                                                    }
                                                }
                                            } label: {
                                                ProductCard(product: $vm.itemsTopSelling[index])
                                            }
                                            .frame(width: 200)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                            
                        }
                        
                        // MARK : Most Viewed
                        if !vm.itemsMostViewed.isEmpty {
                            Section("Most viewed items") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach($vm.itemsMostViewed.indices, id: \.self) { index in
                                            NavigationLink {
                                                ProductDetails(product: $vm.itemsMostViewed[index]) { item in
                                                    if let index = vm.itemsMostViewed.firstIndex(where: {$0.id == item.id}) {
                                                        vm.itemsMostViewed.remove(at: index)
                                                    }
                                                }
                                            } label: {
                                                ProductCard(product: $vm.itemsMostViewed[index])
                                            }
                                            .frame(width: 200)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                        }
                        
                        // MARK : REPORTS
                        if user.canAccessAdmin {
                            Section {
                                HStack {
                                    // MARK : Added to Cart
                                    ReportCardView(title: "Added to cart",
                                                   desc: "\(vm.siteReports.getTotalAddedToCart()) Items added",
                                                   dataSuffix: "Items",
                                                   data: vm.siteReports.getAddedToCartData(), lineColor: .blue, smallSize: true)
                                    
                                    // MARK : Products View
                                    ReportCardView(title: "Products view",
                                                   desc: "\(vm.siteReports.getTotalProductsView()) Views",
                                                   dataSuffix: "Views",
                                                   data: vm.siteReports.getProductsViewsData(),
                                                   lineColor: .mint, smallSize: true)
                                }
                                .listRowSeparator(.hidden)
                                
                            } header: {
                                HStack {
                                    Text("Overview")
                                        .font(.headline)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Picker("Date Range", selection: $vm.staticsDays) {
                                        Text("Today")
                                            .tag(1)
                                        
                                        Text("This Week")
                                            .tag(7)
                                        
                                        Text("This Month")
                                            .tag(30)
                                        
                                        Text("This Quarter")
                                            .tag(90)
                                        
                                        Text("This year")
                                            .tag(365)
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                            
                        }
                        
                        // MARK : Last ordered
                        if !vm.itemsLastOrdered.isEmpty {
                            Section("Last Ordered") {
                                ForEach($vm.itemsLastOrdered.indices, id: \.self) { index in
                                    WarehouseCard(prod: $vm.itemsLastOrdered[index], sold: true)
                                        .background(
                                            NavigationLink("", destination: {
                                                ProductDetails(product: $vm.itemsLastOrdered[index], onDelete: { item in
                                                    if let index = vm.itemsLastOrdered.firstIndex(where: {$0.id == item.id}) {
                                                        vm.itemsLastOrdered.remove(at: index)
                                                    }
                                                })
                                            })
                                        )
                                    
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .isHidden(vm.isLoading)
        .overlay {
            ProgressView()
                .isHidden(!vm.isLoading)
        }
        .refreshable {
            await vm.getContent()
        }
    }
}

#Preview {
    ProductsFragment()
}
