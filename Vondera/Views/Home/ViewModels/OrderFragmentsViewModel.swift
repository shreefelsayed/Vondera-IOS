//
//  OrderFragmentsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import Foundation

class OrderFragmentViewModel : ObservableObject {
    lazy var ordersDao:OrdersDao? = nil
    lazy var user = UserInformation.shared.getUser()
    
    @Published var listOrders = [Order]()
    @Published var isLoading = true
    @Published var errorMsg = ""
    
    init() {
        initalize()
    }
    
    func initalize()  {
        Task {
            do {
                user = UserInformation.shared.getUser()
                ordersDao = OrdersDao(storeId: user!.storeId)
                
                await getOrdersList()
            }
        }
    }
    
    func getOrdersList() async {
        self.isLoading = true
        do {
            self.listOrders = try await ordersDao!.getOrdersByStatue(statue: "Pending")
        } catch {
            self.errorMsg = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
