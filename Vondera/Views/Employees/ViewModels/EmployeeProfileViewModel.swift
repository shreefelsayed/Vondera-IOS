//
//  EmployeeProfileViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation

import FirebaseFirestore

class EmployeeProfileViewModel: ObservableObject {
    var userData:UserData
    var ordersDao:OrdersDao
    var myUser:UserData?
    
    @Published var items = [Order]()
    @Published var isLoading = false
    @Published var canLoadMore = true
    @Published var error = ""
    @Published var isRefreshing = false
    
    private var lastSnapshot:DocumentSnapshot?
    
    
    init(userData:UserData) {
        self.userData = userData
        self.ordersDao = OrdersDao(storeId: userData.storeId)
        
        Task {
            await getData()
            self.myUser = UserInformation.shared.getUser()
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
         
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            let result = try await ordersDao.getUserOrders(id: userData.id, lastSnapShot: lastSnapshot)
            
            DispatchQueue.main.async {
                self.lastSnapshot = result.1
                self.items.append(contentsOf: result.0)
                if result.0.count == 0 {
                    self.canLoadMore = false
                    print("Can't load more data")
                }
                
                self.isLoading = false
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
