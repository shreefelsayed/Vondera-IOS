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
            if let user = UserInformation.shared.user {
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
                .padding()
                
                List {
                    // MARK : 3 Cards with counters
                    Section {
                        NavigationLink(destination: StoreProducts(storeId: user.storeId)) {
                            Label("All Products", systemImage: "cart.fill")
                                .bold()
                        }
                        
                        if user.canAccessAdmin {
                            NavigationLink(destination: StoreCategories(store: user.store!)) {
                                Label("Categories", systemImage: "tablecells.fill.badge.ellipsis")
                                    .bold()
                            }
                            
                            NavigationLink {
                                (user.store?.subscribedPlan?.accessStockReport ?? false) ?
                                AnyView(WarehouseView(storeId: user.storeId)) : AnyView(AppPlans(selectedSlide: 7))
                            } label: {
                                Label("Warehouse", systemImage: "homekit")
                                    .bold()
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSpacing(4)
                    .listRowSeparator(.hidden)
                    
                    // MARK : Top Selling
                    if !vm.itemsTopSelling.isEmpty {
                        Section {
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
                        } header: {
                            HStack {
                                Text("Most Selling Products")
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // MARK : Most Viewed
                    if !vm.itemsMostViewed.isEmpty {
                        Section {
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
                        } header: {
                            Text("Most viewed items")
                                .font(.title3)
                                .bold()
                        }
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
                                    .font(.title3)
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
                        
                    }
                    // MARK : Last ordered
                    if !vm.itemsLastOrdered.isEmpty {
                        Section {
                            ForEach($vm.itemsLastOrdered.indices, id: \.self) { index in
                                NavigationLink(destination: ProductDetails(product: $vm.itemsLastOrdered[index], onDelete: { item in
                                    if let index = vm.itemsLastOrdered.firstIndex(where: {$0.id == item.id}) {
                                        vm.itemsLastOrdered.remove(at: index)
                                    }
                                })) {
                                    WarehouseCard(prod: $vm.itemsLastOrdered[index])
                                }
                                .buttonStyle(.plain)
                                
                            }
                        } header: {
                            Text("Last Ordered")
                                .font(.title3)
                                .bold()
                        }
                    }
                    
                    
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .listRowSeparator(.hidden)
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
