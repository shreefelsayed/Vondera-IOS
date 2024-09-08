//
//  ProductsSearchView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import SwiftUI

class ProductSearchVM : ObservableObject {
    @Published var items = [StoreProduct]()
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var linear = true
    
    init() {
        self.isLoading = true
        Task {
            await getData()
        }
    }
    
    func getData() async {
        do {
            if let storeId = UserInformation.shared.getUser()?.storeId {
                let items = try await ProductsDao(storeId: storeId).getAll(sort: "name")
                DispatchQueue.main.async {
                    self.items = items
                    self.isLoading = false
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ProductsSearchView: View {
    @ObservedObject var vm:ProductSearchVM
    
    init() {
        self.vm = ProductSearchVM()
    }
    
    var body: some View {
        VStack {
            if vm.linear  {
                List {
                    ForEach($vm.items.indices, id: \.self) { index in
                        if vm.items[index].filter(vm.searchText) {
                            NavigationLink(destination: ProductDetails(product: $vm.items[index], onDelete: { item in
                                if let index = vm.items.firstIndex(where: {$0.id == item.id}) {
                                    vm.items.remove(at: index)
                                }
                            })) {
                                WarehouseCard(prod: $vm.items[index], showVariants: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach($vm.items.indices, id: \.self) { index in
                            if $vm.items[index].wrappedValue.filter(vm.searchText) {
                                NavigationLink(destination: ProductDetails(product: $vm.items[index])) {
                                    ProductCard(product: $vm.items[index])
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }.padding()
                }
            }
        }
        .isHidden(vm.isLoading)
        .overlay {
            if vm.items.isEmpty && vm.isLoading {
                ProgressView()
            } else if vm.items.isEmpty && !vm.isLoading {
                EmptyMessageView(systemName: "tag.fill", msg: "No products are added to the store yet !")
            } else if !vm.searchText.isBlank && vm.items.filter({ $0.filter(vm.searchText) }).isEmpty {
                SearchEmptyView(searchText: vm.searchText)
            }
        }
        .searchable(text: $vm.searchText, prompt: Text("Search \($vm.items.count) Products"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        vm.linear.toggle()
                    }
                } label: {
                    Image(systemName: vm.linear ? "lineweight" : "menucard.fill")
                }

            }
        }
        .refreshable {
            vm.searchText = ""
            await vm.getData()
        }
        .navigationTitle("Search Products")
    }
    
    
}

#Preview {
    ProductsSearchView()
}
