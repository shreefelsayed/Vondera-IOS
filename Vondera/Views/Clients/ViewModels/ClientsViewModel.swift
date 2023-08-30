//
//  ClientsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation
import FirebaseFirestore
import AdvancedList
import Combine

class ClientsViewModel: ObservableObject {
    var storeId:String
    
    var clientsDao:ClientsDao
    @Published var state:ListState = .items
    @Published var items = [Client]()
    @Published var canLoadMore = true
    @Published var error = ""
    
    // --> Server search
    private var cancellables = Set<AnyCancellable>()
    @Published var searchText = ""
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
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await getData()
    }
    
    func getData() async {
        guard state != .loading || !canLoadMore else {
            return
        }
        
        do {
            if lastSnapshot == nil { state = .loading }
            
            let result = try await clientsDao.getClients(lastSnapShot: lastSnapshot)
            lastSnapshot = result.1
            items.append(contentsOf: result.0)
            print("Got \(result.0.count) Clients")
            if result.0.count == 0 {
                self.canLoadMore = false
                print("Can't load more data")
            }
            
            initSearch()
            
            state = .items
        } catch {
            if lastSnapshot == nil { state = .error(error as NSError) }
        }
        
    }
    
    func initSearch() {
        $searchText
            .sink { newValue in
                self.searchClient(newValue)
            }
            .store(in: &cancellables)
    }
    
    //01503312121
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
