//
//  LatestViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import Combine
import FirebaseFirestore

class LatestViewModel : ObservableObject {
    var ordersDao:OrdersDao?
    @Published var items = [Order]()
    @Published var searchText = ""
    @Published var uiMessage:String?
    
    
    init() {
        Task {
            if let storeId = UserInformation.shared.user?.storeId {
                ordersDao = OrdersDao(storeId: storeId)
                await getData()
            }
        }
    }
    
    func getData() async {
        do {
            let items = try await ordersDao?.getOrdersByStatue(statue: "Pending")
            self.items = items ?? []
        } catch {
            uiMessage = error.localizedDescription
        }
    }
}
