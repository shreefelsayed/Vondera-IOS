//
//  UserOrderViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import Foundation
import FirebaseFirestore

class UserOrdersViewModel: ObservableObject {
    var id:String = ""
    var storeId:String = ""
    
    // Pagination Values
    @Published var items = [Order]()
    @Published var canLoadMore = true
    @Published var isLoading = false
    @Published var intialDataLoaded = false
    @Published var searchText = ""
    private var lastSnapshot:DocumentSnapshot?
    
    
    init() {
        if let user = UserInformation.shared.user  {
            self.id = user.id
            self.storeId = user.storeId
            
            Task {
                await getIntialData()
            }
        }
    }
    
    func getIntialData() async {
        guard let storeId = UserInformation.shared.user?.storeId, !intialDataLoaded else {
            return
        }
        
            do {
            let result = try await OrdersDao(storeId: storeId).getUserOrders(id: id, lastSnapShot: lastSnapshot)
            
            DispatchQueue.main.async {
                self.lastSnapshot = result.1
                self.items.append(contentsOf: result.0)
                self.canLoadMore = (result.0.count >= OrdersDao.pageSize)
                self.intialDataLoaded = true
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId, !isLoading, canLoadMore, intialDataLoaded else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let result = try await OrdersDao(storeId: storeId).getUserOrders(id: id, lastSnapShot: lastSnapshot)
            
            DispatchQueue.main.async {
                self.lastSnapshot = result.1
                self.items.append(contentsOf: result.0)
                self.canLoadMore = (result.0.count >= OrdersDao.pageSize)
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    // --> Refresh Data
    func refreshData() {
        self.intialDataLoaded = false
        self.isLoading = false
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        Task {
            await getIntialData()
        }
    }
}
