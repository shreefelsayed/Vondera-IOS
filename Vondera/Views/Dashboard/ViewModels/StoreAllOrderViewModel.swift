//
//  StoreAllOrderViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation
import FirebaseFirestore

class StoreAllOrdersViewModel: ObservableObject {
    var storeId:String
    
    var ordersDao:OrdersDao
    
    @Published var items = [Order]()
    @Published var isLoading = false
    @Published var canLoadMore = true
    @Published var error = ""
    @Published var isRefreshing = false
    
    private var lastSnapshot:DocumentSnapshot?
    
    
    init(storeId:String) {
        self.storeId = storeId
        self.ordersDao = OrdersDao(storeId: storeId)
    }
    
    func refreshData() async {
        self.isRefreshing = true
        
        self.isLoading = false
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await getData()
        
        self.isRefreshing = false
    }
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        do {
            self.isLoading = true
            let result = try await ordersDao.getAll(lastSnapShot: lastSnapshot)
            lastSnapshot = result.1
            items.append(contentsOf: result.0)
            
            if result.0.count == 0 {
                self.canLoadMore = false
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
        self.isLoading = false
    }
}
