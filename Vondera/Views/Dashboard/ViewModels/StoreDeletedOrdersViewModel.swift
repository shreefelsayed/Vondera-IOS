//
//  StoreDeletedOrdersViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation
import FirebaseFirestore
import Combine

class StoreDeletedOrdersViewModel: ObservableObject {
    var storeId:String
    
    var ordersDao:OrdersDao
    
    @Published var items = [Order]()
    private var lastSnapshot:DocumentSnapshot?

    
    @Published var isLoading = false
    @Published var canLoadMore = true
    @Published var error = ""
    
    // Search Vars
    @Published var searchText = ""
    @Published var result = [Order]()
    private var cancellables = Set<AnyCancellable>()

    init(storeId:String) {
        self.storeId = storeId
        self.ordersDao = OrdersDao(storeId: storeId)
        
        Task {
            await getData()
            initSearch()
        }
    }
    
    var filteredItems: [Order] {
        guard !searchText.isEmpty else { return items }
        return result
    }
    
    func refreshData() async {
        self.isLoading = false
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await getData()
    }
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        do {
            self.isLoading = true
            let result = try await ordersDao.getDeleted(lastSnapShot: lastSnapshot)
            lastSnapshot = result.1
            items.append(contentsOf: result.0)
            
            if result.0.count == 0 {
                self.canLoadMore = false
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
        self.isLoading = false
    }
    
    func initSearch() {
        $searchText
            .debounce(for: .seconds(1.2), scheduler: RunLoop.main) // Adjust the debounce time as needed
            .removeDuplicates() // To avoid duplicate values
            .sink { [self] newValue in
                if !newValue.isBlank {
                    Task {
                        do {
                            result = try await ordersDao.searchByTextWithStatue(search: searchText, statue: "Deleted", lastSnapshot: nil).items
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
