//
//  AddToCart.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI

struct AddToCart: View {
    @StateObject var viewModel = AddToCartViewModel()
    @State private var selectedProduct: StoreProduct? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            // MARK : Categories
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center) {
                    ForEach(viewModel.categories) { category in
                        CategoryTab(category: category, onClick: {
                            selectCategory(id: category.id)
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
            }
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                if viewModel.products.isEmpty {
                    EmptyMessageView(msg: "No Products are in this category")
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach($viewModel.products.indices, id: \.self) { index in
                            if $viewModel.products[index].wrappedValue.filter(viewModel.searchText) {
                                NavigationLink(destination: ProductDetails(product: $viewModel.products[index])) {
                                    ProductBuyingCard(product: $viewModel.products[index]) {
                                        self.selectedProduct = viewModel.products[index]
                                    }
                                }
                                
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.selectCategory(id: viewModel.selectedCategory)
        }
        .sheet(item: self.$selectedProduct) { prod in
            ProductBuyingSheet(product: .constant(prod))
                .onDisappear {
                    Task {
                        await viewModel.getCart()
                    }
                }
        }
        .searchable(text: $viewModel.searchText, prompt: Text("Search \(viewModel.products.count) Products"))
        .onAppear {
            Task {
                await viewModel.getCart()
            }
        }
        .navigationTitle("New Order")
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
    
    func selectCategory(id:String) {
        Task {
            await viewModel.selectCategory(id: id)
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


#Preview {
    NavigationView {
        AddToCart()
    }
}
