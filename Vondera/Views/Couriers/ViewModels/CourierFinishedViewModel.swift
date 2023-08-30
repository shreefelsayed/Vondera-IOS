//
//  CourierFinishedViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestore

class CourierFinishedViewModel : ObservableObject {
    var courier:Courier
    
    var ordersDao:OrdersDao
    
    @Published var items = [Order]()
    @Published var isLoading = false
    @Published var canLoadMore = true
    @Published var error = ""
    @Published var isRefreshing = false
    
    private var lastSnapshot:DocumentSnapshot?
    
    
    init(courier:Courier) {
        self.courier = courier
        self.ordersDao = OrdersDao(storeId: courier.storeId!)
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
        
        self.isLoading = true
        do {
            let result = try await ordersDao.getCouriersFinished(id: courier.id, lastSnapShot: lastSnapshot)
            lastSnapshot = result.1
            items.append(contentsOf: result.0)
            
            if result.0.count == 0 {
                self.canLoadMore = false
                print("Can't load more data")
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        self.isLoading = false
    }
}

