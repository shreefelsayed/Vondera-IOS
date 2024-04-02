//
//  StoreExpansesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

class StoreExpansesViewModel : ObservableObject {
    @Published var isLoading = false
    
    @Published var items = [Expense]()
    @Published var result = [Expense]()

    @Published var canLoadMore = true
    @Published var msg:LocalizedStringKey?
    
    // --> Server search
    private var cancellables = Set<AnyCancellable>()
    @Published var searchText = ""
    
    private var lastSnapshot:DocumentSnapshot?
    
    init() {
        Task {
            await getData()
            initSearch()
        }
    }
    
    
    func deleteItem(item:Expense) {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        Task {
            try await ExpansesDao(storeId: storeId).delete(id:item.id)
            DispatchQueue.main.sync {
                ToastManager.shared.showToast(msg: "Expanses Deleted", toastType: .success)
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
        
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let result = try await ExpansesDao(storeId: storeId).getExpanses(lastSnapShot: lastSnapshot)
            DispatchQueue.main.sync {
                self.lastSnapshot = result.1
                self.items.append(contentsOf: result.0)
                if result.0.count == 0 {
                    self.canLoadMore = false
                }
                
                self.isLoading = false
            }
        } catch {
            self.isLoading = false
        }
        
    }
    
    func initSearch() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        $searchText
            .debounce(for: .seconds(1.2), scheduler: RunLoop.main) // Adjust the debounce time as needed
            .removeDuplicates() // To avoid duplicate values
            .sink { [self] newValue in
                if !newValue.isBlank {
                    Task {
                        do {
                            let result = try await ExpansesDao(storeId: storeId).search(text: searchText).sorted(by: { $0.date.toDate() < $1.date.toDate() })
                            
                            DispatchQueue.main.sync {
                                self.result = result
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
