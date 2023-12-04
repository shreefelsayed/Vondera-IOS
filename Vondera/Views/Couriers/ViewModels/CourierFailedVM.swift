//
//  CourierFailedVM.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/11/2023.
//

import Foundation
import FirebaseFirestore

class CourierFailedVM : ObservableObject {
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
        
        Task {
            await refreshData()
        }
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
            let result = try await ordersDao.getCourierFailed(id: courier.id, lastSnapShot: lastSnapshot)
            DispatchQueue.main.async {
                self.lastSnapshot = result.lastDocument
                self.items.append(contentsOf: result.items)
                
                if result.items.count == 0 {
                    self.canLoadMore = false
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        self.isLoading = false
    }
}

