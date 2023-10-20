//
//  UserOrderViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import Foundation
import FirebaseFirestore

class UserOrdersViewModel: ObservableObject {
    var id:String
    var storeId:String
    private var ordersDao:OrdersDao
    
    @Published var isLoading = false
    @Published var items = [Order]()
    
    @Published var canLoadMore = true
    @Published var error = ""
    
    private var lastSnapshot:DocumentSnapshot?
    
    
    init(id:String, storeId:String) {
        self.id = id
        self.storeId = storeId
        self.ordersDao = OrdersDao(storeId: storeId)
        
        Task {
            await getData()
        }
    }
    
    
    
    func refreshData() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await getData(refreshing: true)
    }
    
    func getData(refreshing:Bool = false) async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        do {
            isLoading = true
            
            let result = try await ordersDao.getUserOrders(id: id, lastSnapShot: lastSnapshot)
            
            lastSnapshot = result.1
            items.append(contentsOf: result.0)
            
            if result.0.count == 0 {
                self.canLoadMore = false
                print("Can't load more data")
            }
            
            isLoading = false
        } catch {
            isLoading = false
        }
        
    }
}
