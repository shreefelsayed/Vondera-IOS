//
//  StoreExpansesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import AdvancedList

class StoreExpansesViewModel : ObservableObject {
    var storeId:String
    
    var expansesDao:ExpansesDao
    @Published var state:ListState = .items
    @Published var items = [Expense]()
    @Published var canLoadMore = true
    @Published var error = ""
    
    // --> Server search
    private var cancellables = Set<AnyCancellable>()
    @Published var searchText = ""
    @Published var result = [Expense]()
    
    private var lastSnapshot:DocumentSnapshot?
    
    var filteredItems: [Expense] {
        guard !searchText.isEmpty else { return items }
        return result
    }
    
    init(storeId:String) {
        self.storeId = storeId
        self.expansesDao = ExpansesDao(storeId: storeId)
        
        Task {
            await getData()
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
        DispatchQueue.main.sync {
            self.canLoadMore = true
            self.lastSnapshot = nil
            self.items.removeAll()
        }
        await getData()
    }
    
    func getData() async {
        guard state != .loading || !canLoadMore else {
            return
        }
        
        do {
            DispatchQueue.main.sync {
                if lastSnapshot == nil { state = .loading }
            }
            
            let result = try await expansesDao.getExpanses(lastSnapShot: lastSnapshot)
            
            
            DispatchQueue.main.sync {
                lastSnapshot = result.1
                items.append(contentsOf: result.0)
                if result.0.count == 0 {
                    self.canLoadMore = false
                }
                initSearch()
                state = .items
            }
        } catch {
            DispatchQueue.main.sync {
                if lastSnapshot == nil { state = .error(error as NSError) }
            }
        }
        
    }
    
    func initSearch() {
        $searchText
            .sink { newValue in
                self.search(newValue)
            }
            .store(in: &cancellables)
    }
    
    func search(_ text:String) {
        guard !text.isBlank else {
            return
        }
        
        Task {
            do {
                let result = try await self.expansesDao.search(text: text)
                DispatchQueue.main.sync {
                    self.result = result.sorted(by: { $0.date!.toDate() < $1.date!.toDate() })
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}
