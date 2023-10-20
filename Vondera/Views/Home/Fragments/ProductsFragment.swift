//
//  ProductsFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import SwiftUI

struct ProductsFragment: View {
    @ObservedObject var myUser = UserInformation.shared

    @State var isLoading = true
    
    @State var itemsTopSelling = [StoreProduct]()
    @State var itemsMostViewed = [StoreProduct]()
    
    var body: some View {
        VStack {
            if let user = myUser.user {
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
                        
                        NavigationLink(destination: ProductsSearchView(storeId: user.storeId)) {
                            Image(systemName: "magnifyingglass.circle.fill")
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.title2)
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

                        NavigationLink(destination: StoreCategories(store: user.store!)) {
                            Label("Categories", systemImage: "tablecells.fill.badge.ellipsis")
                                .bold()
                        }
                                                
                        NavigationLink(destination: WarehouseView(storeId: user.storeId)) {
                            Label("Warehouse", systemImage: "homekit")
                                .bold()
                        }
                        
                    }
                    .buttonStyle(.plain)
                    .listRowSpacing(4)
                    .listRowSeparator(.hidden)
                    
                    // MARK : Latest Orders
                    
                    if !itemsTopSelling.isEmpty {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach($itemsTopSelling.indices, id: \.self) { index in
                                        NavigationLink {
                                            ProductDetails(product: $itemsTopSelling[index])
                                        } label: {
                                            ProductCard(product: $itemsTopSelling[index])
                                                
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
                                
                                Text("See All")
                                    .underline()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    
                    if !itemsMostViewed.isEmpty {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach($itemsMostViewed.indices, id: \.self) { index in
                                        NavigationLink {
                                            ProductDetails(product: $itemsMostViewed[index])
                                        } label: {
                                            ProductCard(product: $itemsMostViewed[index])
                                                
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
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .listRowSeparator(.hidden)
            }
           
        }
        .isHidden(isLoading)
        .overlay {
            ProgressView()
                .isHidden(!isLoading)
        }
        .task {
            await getContent()
        }
        .refreshable {
            await getContent()
        }
    }
    
    func getContent() async {
        if let storeId = myUser.user?.storeId {
            do {
                
                let mostSelling = try await ProductsDao(storeId: storeId).getTopSelling()
                
                let mostViewed = try await ProductsDao(storeId: storeId).getMostVieweed()
                
                DispatchQueue.main.async {
                    self.itemsTopSelling = mostSelling
                    self.itemsMostViewed = mostViewed
                    self.isLoading = false
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ProductsFragment()
}
