//
//  InStockViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import FirebaseFirestore

class AlmostOutViewModel: ObservableObject {
    var storeId:String
    var productsDao:ProductsDao
    var storesDao = StoresDao()

    @Published var isLoading = false
    @Published var items = [StoreProduct]()
    @Published var canLoadMore = true
    @Published var error = ""
    
    private var lastSnapshot:DocumentSnapshot?
    
    
    init( storeId:String) {
        self.storeId = storeId
        self.productsDao = ProductsDao(storeId: storeId)
        
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
        guard !isLoading && canLoadMore else {
            return
        }
        
        do {
            isLoading = true
           
            let store = try await storesDao.getStore(uId: storeId)
            let result = try await productsDao.getStockLessThen(almostOut: store.almostOut ?? 20, lastSnapShot: lastSnapshot)
            
            DispatchQueue.main.sync {
                lastSnapshot = result.1
                items.append(contentsOf: result.0)
                self.canLoadMore = !result.0.isEmpty
                isLoading = false
            }
        } catch {
            isLoading = false
        }
    }
}
