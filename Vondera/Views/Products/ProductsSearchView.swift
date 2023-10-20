//
//  ProductsSearchView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import SwiftUI

struct ProductsSearchView: View {
    var storeId:String
    
    @State var items = [StoreProduct]()
    @State var isLoading = true
    @State var searchText = ""
    
    var body: some View {
        List {
            ForEach($items.indices, id: \.self) { index in
                if items[index].filter(searchText) {
                    WarehouseCard(prod: $items[index])
                }
            }
        }
        .isHidden(isLoading)
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Text("Search \(items.count) Products"))
        .overlay {
            if items.isEmpty && isLoading {
                ProgressView()
            } else if items.isEmpty && !isLoading {
                EmptyMessageView(systemName: "tag.fill", msg: "No products are added to the store yet !")
            } else if !searchText.isBlank && items.filter({ $0.filter(searchText) }).isEmpty {
                EmptyMessageView(systemName: "tmagnifyingglass", msg: "No result found for \(searchText)")
            }
        }
        .refreshable {
            searchText = ""
            await getData()
        }
        .navigationTitle("Search Products")
        .task {
            await getData()
        }
    }
    
    func getData() async {
        do {
            let items = try await ProductsDao(storeId: storeId).getAll(sort: "name")
            DispatchQueue.main.async {
                self.items = items
                self.isLoading = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ProductsSearchView(storeId: Store.Qotoofs())
}
