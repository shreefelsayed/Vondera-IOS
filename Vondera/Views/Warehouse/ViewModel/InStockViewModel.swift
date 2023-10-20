//
//  InStockViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import FirebaseFirestore

class InStockViewModel: ObservableObject {
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
            
            let result = try await productsDao.getInStock(lastSnapShot: lastSnapshot)
            
            lastSnapshot = result.1
            items.append(contentsOf: result.0)
            self.canLoadMore = !result.0.isEmpty
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
