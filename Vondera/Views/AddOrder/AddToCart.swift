//
//  AddToCart.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI

struct AddToCart: View {
    var storeId:String
    @StateObject var viewModel:AddToCartViewModel
    @State private var selectedProduct: Product? = nil
    
    init(storeId: String) {
        self.storeId = storeId
        self._viewModel = StateObject(wrappedValue: AddToCartViewModel(storeId: storeId))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            PullToRefreshOld(coordinateSpaceName: "scrollView") {
                Task {
                    await viewModel.selectCategory(id: viewModel.selectedCategory)
                }
            }
            
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
                    VStack(alignment: .center) {
                        if !viewModel.products.isEmpty {
                            SearchBar(text: $viewModel.searchText, hint: "Search \(viewModel.products.count) Products")
                                .padding(.horizontal, 8)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(viewModel.filteredItems) { product in
                                NavigationLink(destination: ProductDetails(product: product)) {
                                    ProductBuyingCard(product: product) {
                                        self.selectedProduct = product
                                    }
                                }.buttonStyle(PlainButtonStyle())
                                
                            }
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "scrollView")
        .sheet(item: self.$selectedProduct) { prod in
           ProductBuyingSheet(product: prod)
                .onDisappear {
                    Task {
                        await viewModel.getCart()
                    }
                }
        }
        .onAppear {
            Task {
                await viewModel.getCart()
            }
        }
        .navigationTitle("New Order")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: Cart(storeId: storeId)) {
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


struct AddToCart_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddToCart(storeId: "lcvPuRAIVVUnRcZpttlPsRPLqoY2")
        }
        
    }
}
