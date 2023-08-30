//
//  LatestViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import Combine

class LatestViewModel : ObservableObject {
    lazy var ordersDao:OrdersDao? = nil
    lazy var user:UserData? = nil
    
    @Published var items = [Order]()
    @Published var searchText = ""
    
    @Published var isLoading = true
    @Published var errorMsg = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    var filteredItems: [Order] {
        guard !searchText.isEmpty else { return items }
        
        return items.filter { order in
            order.filter(searchText: searchText)
        }
    }
    
    init() {
        initalize()
    }
    
    func initalize()  {
        Task {
            user = await LocalInfo().getLocalUser()!
            ordersDao = OrdersDao(storeId: user!.storeId)
            await getOrdersList()
        }
    }
    
    func getOrdersList() async {
        DispatchQueue.main.sync {
            self.isLoading = true
        }
        
        do {
            let incomeItems = try await ordersDao!.getOrdersByStatue(statue: "Pending")
            DispatchQueue.main.sync {
                self.items = incomeItems
            }
        } catch {
            DispatchQueue.main.sync {
                self.errorMsg = error.localizedDescription
            }
        }
        
        DispatchQueue.main.sync {
            self.isLoading = false

        }
    }
}
