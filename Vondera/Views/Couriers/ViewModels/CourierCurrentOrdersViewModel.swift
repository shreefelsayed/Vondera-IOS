//
//  CourierCurrentOrdersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import Combine

class CourierCurrentOrdersViewModel : ObservableObject {
    var storeId:String
    var courierId:String
    var ordersDao:OrdersDao
        
    
    @Published var errorMsg = ""
    @Published var isLoading = false
    @Published var searchText = ""
    
    @Published var items = [Order]()
    var filteredItems: [Order] {
        guard !searchText.isEmpty else { return items }
        return items.filter { order in
            order.filter(searchText: searchText)
        }
    }
    
    init(storeId:String, courierId:String) {
        self.storeId = storeId
        self.courierId = courierId
        self.ordersDao = OrdersDao(storeId: storeId)
        
        Task {
            await getCourierOrders()
        }
    }
    
    func getCourierOrders() async {
        self.isLoading = true
        
        do {
            items = try await ordersDao.getPendingCouriersOrder(id: courierId)
        } catch {
            showError(msg: error.localizedDescription)
        }
        
        searchText = ""
        self.isLoading = false
    }
    
    private func showError(msg:String) {
        self.errorMsg = msg
    }
}
