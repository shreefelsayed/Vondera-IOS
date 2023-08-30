//
//  ClientOrdersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import Foundation
import AdvancedList

class ClientOrdersViewModel : ObservableObject {
    var clientId:String
    var ordersDoa:OrdersDao
    @Published var state:ListState = .items
    @Published var items = [Order]()
    @Published var error = ""
    
    init(id:String, storeId:String) {
        self.clientId = id
        self.ordersDoa = OrdersDao(storeId: storeId)
    }
    
    func refreshData() async {
        self.items.removeAll()
        await getData()
    }
    
    func getData() async {
        guard state != .loading else {
            return
        }
        
        state = .loading
        
        do {
            items = try await ordersDoa.getClientOrders(id: clientId)
            state = .items
        } catch {
            state = .error(error as NSError)

        }
        
    }
}
