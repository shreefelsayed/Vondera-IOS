//
//  StoreProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct StoreProducts: View {
    var storeId:String
    @ObservedObject var viewModel:StoreProductsViewModel
    @State var myUser:UserData?
    
    init(storeId: String) {
        self.storeId = storeId
        self.viewModel =  StoreProductsViewModel(storeId: storeId)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            PullToRefreshOld(coordinateSpaceName: "scrollView") {
                Task {
                    await viewModel.selectCategory(id: viewModel.selectedCategory)
                }
            }
            
            VStack(alignment: .leading) {
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
                            
                            LazyVGrid(columns: [GridItem(.flexible()),
                                                GridItem(.flexible())]) {
                                ForEach(viewModel.filteredItems) { product in
                                    NavigationLink(destination: ProductDetails(product: product)) {
                                        ProductCard(product: product)
                                    }.buttonStyle(PlainButtonStyle())
                                    
                                }
                            }
                        }
                    }
                }
            }
           
        }
        .coordinateSpace(name: "scrollView")
        .navigationTitle("Products")
        .toolbar {
            if myUser != nil && myUser!.canAccessAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add") {
                        AddProductView(storeId: storeId)
                    }
                }
            }
            
        }
        .onAppear {
            Task {
                self.myUser = await LocalInfo().getLocalUser()
            }
        }
    }
    
    func selectCategory(id:String) {
        Task {
            await viewModel.selectCategory(id: id)
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
