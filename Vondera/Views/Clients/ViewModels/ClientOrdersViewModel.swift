//
//  ClientOrdersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import Foundation

class ClientOrdersViewModel : ObservableObject {
    var clientId:String
    var ordersDoa:OrdersDao
    
    
    @Published var isLoading = false
    @Published var items = [Order]()
    @Published var error = ""
    @Published var searchText = ""
    
    init(id:String, storeId:String) {
        self.clientId = id
        self.ordersDoa = OrdersDao(storeId: storeId)
        
        Task {
            await getData()
        }
    }
    
    var filteredItems: [Order] {
        guard !searchText.isEmpty else { return items }
        return items.filter { order in
            order.filter(searchText: searchText)
        }
    }
        
    func refreshData() async {
        self.items.removeAll()
        await getData()
    }
    
    func getData() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        do {
            items = try await ordersDoa.getClientOrders(id: clientId)
            isLoading = false
        } catch {
            isLoading = false
        }
        
    }
}
