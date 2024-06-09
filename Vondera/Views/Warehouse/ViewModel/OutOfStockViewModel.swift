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
        
        self.isLoading = true
        do {
            let result = try await productsDao.getOutOfStock(lastSnapShot: lastSnapshot)
            DispatchQueue.main.async {
                let data = result.0.filter({$0.alwaysStocked == false})
                self.lastSnapshot = result.1
                self.items.append(contentsOf: data)
                self.canLoadMore = !result.0.isEmpty
            }
           
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Out Of Stock")
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
