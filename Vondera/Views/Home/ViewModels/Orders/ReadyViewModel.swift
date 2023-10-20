//
//  ReadyViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import Combine
import FirebaseFirestore

class ReadyViewModel : ObservableObject {
    
    var ordersDao:OrdersDao?
    @Published var items = [Order]()
    @Published var searchText = ""
    @Published var uiMessage:String?
    
    
    init() {
        Task {
            guard let myUser = UserInformation.shared.getUser() else {
                return
            }
            
            ordersDao = OrdersDao(storeId: myUser.storeId)
            await getData()
        }
    }
    
    func getData() async {
        do {
            let items = try await ordersDao?.getOrdersByStatue(statue: "Assembled")
            self.items = items ?? []
        } catch {
            uiMessage = error.localizedDescription
        }
    }
}
