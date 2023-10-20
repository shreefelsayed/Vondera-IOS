//
//  ClientsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation
import FirebaseFirestore
import Combine

class ClientsViewModel: ObservableObject {
    var storeId:String
    
    var clientsDao:ClientsDao
    @Published var items = [Client]()
    @Published var canLoadMore = true
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()

    // --> Server search
    @Published var searchText = ""
    @Published var sortIndex = "lastOrder" {
        didSet {
            Task {
                await refreshData()
            }
        }
    }
    
    @Published var result = [Client]()

    private var lastSnapshot:DocumentSnapshot?
    
    var filteredItems: [Client] {
        guard !searchText.isEmpty else { return items }
        return result
    }
    
    init(storeId:String) {
        self.storeId = storeId
        self.clientsDao = ClientsDao(storeId: storeId)
        
        Task {
            await getData()
        }
    }
    
    func refreshData() async {
        self.lastSnapshot = nil
        self.canLoadMore = true
        self.isLoading = false
        self.items.removeAll()
        self.searchText = ""
        
        await getData()
    }
    
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        DispatchQueue.main.async { [self] in
            isLoading = true
        }
        
        do {
            let result = try await clientsDao.getClients(sort: sortIndex, lastSnapShot: lastSnapshot)
            DispatchQueue.main.async { [self] in
                lastSnapshot = result.1
                items.append(contentsOf: result.0)
                if result.0.count == 0 {
                    self.canLoadMore = false
                }
                initSearch()
                isLoading = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func initSearch() {
        $searchText
            .debounce(for: .seconds(1.2), scheduler: RunLoop.main) // Adjust the debounce time as needed
            .removeDuplicates() // To avoid duplicate values
            .sink { [weak self] newValue in
                if !newValue.isBlank {
                    self?.searchClient(newValue)
                }
            }
            .store(in: &cancellables)
    }
    
    func searchClient(_ name:String) {
        guard !name.isBlank else {
            return
        }
        
        Task {
            do {
                let result = try await self.clientsDao.search(search: name, lastSnapShot: nil)
                DispatchQueue.main.sync {
                    self.result = result.0
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}
