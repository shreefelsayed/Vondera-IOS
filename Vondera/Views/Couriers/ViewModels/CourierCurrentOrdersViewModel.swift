//
//  CourierCurrentOrdersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import Combine

class CourierCurrentOrdersViewModel : ObservableObject {
    var storeId:String
    var courierId:String
    var ordersDao:OrdersDao
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var orders = [Order]()
    @Published var filteredItems = [Order]()
    @Published var errorMsg = ""
    @Published var isLoading = false
    @Published var searchText = ""
    
    init(storeId:String, courierId:String) {
        self.storeId = storeId
        self.courierId = courierId
        self.ordersDao = OrdersDao(storeId: storeId)
        
        Task {
            await getCourierOrders()
        }
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterItems(with: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterItems(with searchText: String = "") {
        if searchText.isEmpty {
            filteredItems = orders
        } else {
            filteredItems = orders.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.phone.localizedCaseInsensitiveContains(searchText)
                || $0.gov.localizedCaseInsensitiveContains(searchText)
                || $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    
    func getCourierOrders() async {
        self.isLoading = true
        
        do {
            orders = try await ordersDao.getPendingCouriersOrder(id: courierId)
        } catch {
            showError(msg: error.localizedDescription)
        }
        
        searchText = ""
        self.isLoading = false
    }
    
    private func showError(msg:String) {
        self.errorMsg = msg
    }
}
