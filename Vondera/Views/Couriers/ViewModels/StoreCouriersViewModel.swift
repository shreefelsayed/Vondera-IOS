//
//  StoreCouriersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation

class StoreCouriersViewModel : ObservableObject {
    private var storeId:String
    private var couriersDao:CouriersDao
    
    @Published var couriers = [Courier]()
    @Published var searchText = ""
    @Published var errorMsg = ""
    @Published var isLoading = false
    
    init(storeId:String) {
        self.storeId = storeId
        self.couriersDao = CouriersDao(storeId: storeId)
        
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
        self.isLoading = true
        
        do {
            couriers = try await couriersDao.getByStatue()
        } catch {
            showError(msg: error.localizedDescription)
        }
        
        self.isLoading = false
    }
    
    private func showError(msg:String) {
        self.errorMsg = msg
    }
}
