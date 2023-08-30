//
//  OrderSearchViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import Foundation
import FirebaseFirestore
import Combine

class OrderSearchViewModel: ObservableObject {
    var storeId:String
    var ordersDao:OrdersDao
    var result = [Order]()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var searchText = ""
    
    init(storeId:String) {
        self.storeId = storeId
        self.ordersDao = OrdersDao(storeId: storeId)
        
        initSearch()
    }
    
    func initSearch() {
        $searchText
            .sink { newValue in
                self.searchOrder(newValue)
            }
            .store(in: &cancellables)
    }
    
    func searchOrder(_ search:String) {
        guard !search.isBlank else {
            result.removeAll()
            return
        }
        
        Task {
            do {
                var indexBy = getIndex(search)
                let result = try await self.ordersDao.search(search: search, field: indexBy, lastSnapShot: nil)
                DispatchQueue.main.sync {
                    self.result = result.0
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func getIndex(_ value:String) -> String {
        if value.isPhoneNumber {
            return "phone"
        } else if value.isNumeric && !value.isPhoneNumber {
            return "id"
        }
        
        return "name"
    }
    
}
