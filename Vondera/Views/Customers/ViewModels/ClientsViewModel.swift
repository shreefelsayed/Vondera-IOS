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
    @Published var items = [Client]()
    @Published var canLoadMore = true
    @Published var isLoading = false
    @Published var intialDataLoaded = false

    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var lastSnapshot:DocumentSnapshot?
    
    // --> Server search
    
    @Published var sortIndex = "lastOrder" {
        didSet {
            Task {
                await refreshData()
            }
        }
    }
    
    @Published var result = [Client]()

    var filteredItems: [Client] {
        guard !searchText.isEmpty else { return items }
        return result
    }
    
    init() {
        initSearch()
        
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        self.items.removeAll()
        self.lastSnapshot = nil
        
        self.intialDataLoaded = false
        self.isLoading = false
        self.canLoadMore = true
        
        await getData()
    }
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId, canLoadMore,!isLoading else {
            return
        }
        
        DispatchQueue.main.async {
            if self.intialDataLoaded {
                self.isLoading = true
            }
        }
        
        do {
            let result = try await ClientsDao(storeId: storeId).getClients(sort: sortIndex, lastSnapShot: lastSnapshot)
            DispatchQueue.main.async {
                self.lastSnapshot = result.lastDocument
                self.items.append(contentsOf: result.items)
                self.canLoadMore = !result.items.isEmpty
                self.intialDataLoaded = true
                self.isLoading = false
                print("Got new items \(result.items.count)")
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
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
                if let storeId = UserInformation.shared.user?.storeId {
                    let result = try await ClientsDao(storeId: storeId).search(search: name, lastSnapShot: nil)
                    DispatchQueue.main.sync {
                        self.result = result.0
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}
