//
//  InStockViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import FirebaseFirestore

class OutOfStockViewModel: ObservableObject {
    var storeId:String
    var productsDao:ProductsDao
    
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
            DispatchQueue.main.async { [self] in
                isLoading = true
            }
            let result = try await productsDao.getOutOfStock(lastSnapShot: lastSnapshot)
            DispatchQueue.main.async { [self] in
                lastSnapshot = result.1
                items.append(contentsOf: result.0)
                self.canLoadMore = !result.0.isEmpty
                isLoading = false
            }
           
        } catch {
            DispatchQueue.main.async { [self] in
                isLoading = false
            }
        }
    }
}
