//
//  StoreCouriersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation

class StoreCouriersViewModel : ObservableObject {
    @Published var couriers = [Courier]()
    @Published var searchText = ""
    @Published var isLoading = false
    
    init() {
        Task {
            await getCouriers()
        }
    }
    
    var filteredItems: [Courier] {
        guard !searchText.isEmpty else { return couriers }
        return couriers.filter { courier in
            courier.filter(searchText)
        }
    }
    
    
    func getCouriers() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        DispatchQueue.main.async {
            self.couriers.removeAll()
            self.isLoading = true
        }
        
        if let result = try? await CouriersDao(storeId: storeId).getByStatue() {
            DispatchQueue.main.async {
                self.couriers = result
                self.isLoading = false
            }
        }
    }
}
