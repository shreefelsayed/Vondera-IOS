//
//  InStockViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import FirebaseFirestore

class AlwaysStockedViewModel: ObservableObject {
    private var storeId:String
    private var productsDao:ProductsDao
    private var lastSnapshot:DocumentSnapshot?
    
    @Published var isLoading = false
    @Published var items = [StoreProduct]()
    @Published var canLoadMore = true
    @Published var error = ""
    
    init( storeId:String) {
        self.storeId = storeId
        self.productsDao = ProductsDao(storeId: storeId)
        
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        await getData()
    }
    
    func getData() async {
        guard !isLoading && canLoadMore else {
            return
        }
        
        self.isLoading = true
        do {
            let result = try await productsDao.getAlwaysStocked(lastSnapShot: lastSnapshot)
            DispatchQueue.main.async {
                self.lastSnapshot = result.1
                self.items.append(contentsOf: result.0)
                self.canLoadMore = !result.0.isEmpty
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        self.isLoading = false
    }
}
