//
//  FeaturedProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast

struct FeaturedProducts: View {
    
    @State var listProducts = [StoreProduct]()
    @State var isLoading = false
    @State var showSheet = false
    
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:String?
    @Environment(\.presentationMode) private var presentationMode
    
    
    var body: some View {
        List {
            ForEach($listProducts) { product in
                NavigationLink(destination: ProductDetails(product: product, onDelete: { item in
                    if let index = listProducts.firstIndex(where: {$0.id == item.id}) {
                        listProducts.remove(at: index)
                    }
                })) {
                    WarehouseCard(prod: product, showVariants: false)
                }
                .buttonStyle(.plain)
                
            }
            .onDelete { indexSet in
                removeItem(indexSet, listProducts[indexSet.first ?? 0])
            }
        }
        .overlay(content: {
            if isLoading {
                ProgressView()
            } else if !isLoading && listProducts.isEmpty {
                EmptyMessageViewWithButton(systemName: "star.slash", msg: "No Products are featured on the website") {
                    Button("Add product to featured") {
                        showSheet.toggle()
                    }
                    .buttonStyle(.bordered)
                }
            }
        })
        .listStyle(.plain)
        .refreshable {
            await getFeatured()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    showSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showSheet, content: {
            NavigationStack {
                PickProductView(skiped: listProducts, isPresented: $showSheet) { product in
                    addProduct(product)
                }
            }
        })
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .task {
            isLoading = true
            await getFeatured()
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        }
        .navigationTitle("Featured Products")
    }
    
    func addProduct(_ product:StoreProduct) {
        guard !listProducts.contains(product) else {
            return
        }
        
        msg = "Product added to featured"
        listProducts.append(product)
        Task {
            let data = ["featured" : true]
            try? await ProductsDao(storeId: product.storeId).update(id: product.id, hashMap:data)
        }
    }
    
    func removeItem(_ index:IndexSet, _ product:StoreProduct) {
        listProducts.remove(atOffsets: index)
        Task {
            let data = ["featured" : false]
            try? await ProductsDao(storeId: product.storeId).update(id: product.id, hashMap:data)
        }
    }
    
    func getFeatured() async {
        if let storeId = user.user?.storeId {
            if let products = try? await ProductsDao(storeId: storeId).getFeatured() {
                DispatchQueue.main.async {
                    self.listProducts = products
                    self.isLoading = false
                }
            }
        }
    }
}

struct PickProductView : View {
    var skiped:[StoreProduct]
    @Binding var isPresented:Bool
    var onClicked:((StoreProduct) -> ())
    
    @State private var isLoading = false
    @State private var products = [StoreProduct]()
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach($products.indices, id: \.self) { index in
                        if $products[index].wrappedValue.filter(searchText) {
                            ProductCard(product: $products[index])
                                .buttonStyle(.plain)
                                .onTapGesture {
                                    onClicked(products[index])
                                    isPresented = false
                                }
                        }
                    }
                }
            }
        }
        .overlay(content: {
            if isLoading {
                ProgressView()
            } else if !isLoading && products.isEmpty {
                
                EmptyMessageView(msg: "No Products are added to the store")
            }
        })
        .searchable(text: $searchText, prompt: Text("Search \(products.count) Products"))
        .navigationTitle("Products")
        .task {
            if let storeId = UserInformation.shared.user?.storeId {
                if let items = try? await ProductsDao(storeId: storeId).getVisible() {
                    DispatchQueue.main.async {
                        // --> Remove existed items
                        var finalItems = [StoreProduct]()
                        for product in items {
                            if !skiped.contains(product) {
                                finalItems.append(product)
                            }
                        }
                        
                        self.products = finalItems
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    FeaturedProducts()
}
