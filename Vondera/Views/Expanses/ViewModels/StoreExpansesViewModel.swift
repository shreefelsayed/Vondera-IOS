//
//  StoreExpansesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import Foundation
import Combine
import FirebaseFirestore

class StoreExpansesViewModel : ObservableObject {
    var storeId:String
    
    var expansesDao:ExpansesDao
    @Published var isLoading = false
    
    @Published var items = [Expense]()
    @Published var result = [Expense]()

    @Published var canLoadMore = true
    @Published var msg:String?
    
    // --> Server search
    private var cancellables = Set<AnyCancellable>()
    @Published var searchText = ""
    
    private var lastSnapshot:DocumentSnapshot?
    
    init(storeId:String) {
        self.storeId = storeId
        self.expansesDao = ExpansesDao(storeId: storeId)
        
        Task {
            await getData()
            initSearch()
        }
    }
    
    
    func deleteItem(item:Expense) {
        Task {
            try await expansesDao.delete(id:item.id)
            DispatchQueue.main.sync {
                items.removeAll(where: { $0.id == item.id })
            }
        }
    }
    
    func refreshData() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        self.searchText = ""
        await getData()
    }
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        do {
            self.isLoading = true
            let result = try await expansesDao.getExpanses(lastSnapShot: lastSnapshot)
                lastSnapshot = result.1
                items.append(contentsOf: result.0)
                if result.0.count == 0 {
                    self.canLoadMore = false
                }
                
                isLoading = false
            
        } catch {
            isLoading = false
        }
        
    }
    
    func initSearch() {
        $searchText
            .debounce(for: .seconds(1.2), scheduler: RunLoop.main) // Adjust the debounce time as needed
            .removeDuplicates() // To avoid duplicate values
            .sink { [self] newValue in
                if !newValue.isBlank {
                    Task {
                        do {
                            result = try await self.expansesDao.search(text: searchText).sorted(by: { $0.date!.toDate() < $1.date!.toDate() })
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
