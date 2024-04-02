//
//  ClientOrdersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import Foundation

class ClientOrdersViewModel : ObservableObject {
    var clientId:String
    
    @Published var isLoading = false
    @Published var items = [Order]()
    @Published var error = ""
    @Published var searchText = ""
    
    init(id:String) {
        self.clientId = id
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
        
        self.isLoading = true
        
        do {
            if let storeId = UserInformation.shared.user?.storeId {
                let results = try await OrdersDao(storeId: storeId).getClientOrders(id: clientId)
                
                DispatchQueue.main.async {
                    self.items = results
                    self.isLoading = false
                }
            }
        } catch {
            isLoading = false
        }
        
    }
}
