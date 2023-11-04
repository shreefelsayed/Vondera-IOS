//
//  StoreProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023
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
            VStack(alignment: .leading) {
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
                            }
                            .buttonStyle(.plain)
                            
                        }
                    }
                }
            }
        }
        .overlay(content: {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.products.isEmpty {
                EmptyMessageView(msg: "No Products are in this category")
            }
        })
        .refreshable {
            await viewModel.selectCategory(id: viewModel.selectedCategory)
        }
        .searchable(text: $viewModel.searchText, prompt: Text("Search \(viewModel.products.count) Products"))
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
            
            if let myUser = myUser, myUser.canAccessAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add") {
                        AddProductView(storeId: storeId)
                    }
                }
            }
        }
        .onAppear {
            self.myUser = UserInformation.shared.getUser()
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
