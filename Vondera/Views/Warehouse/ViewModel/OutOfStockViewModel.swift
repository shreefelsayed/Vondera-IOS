//
//  InStockViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import FirebaseFirestore
import AdvancedList

class OutOfStockViewModel: ObservableObject {
    var storeId:String
    var productsDao:ProductsDao
    
    @Published var state:ListState = .items
    @Published var items = [Product]()
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
        await getData(refreshing: true)
    }
    
    func getData(refreshing:Bool = false) async {
        guard state != .loading || !canLoadMore else {
            return
        }
        
        do {
            DispatchQueue.main.sync {
                if lastSnapshot == nil { state = .loading }
            }
           
            let result = try await productsDao.getOutOfStock(lastSnapShot: lastSnapshot)
            
            DispatchQueue.main.sync {
                lastSnapshot = result.1
                items.append(contentsOf: result.0)
                self.canLoadMore = !result.0.isEmpty
                state = .items
            }
        } catch {
            DispatchQueue.main.sync {
                if lastSnapshot == nil  { state = .error(error as NSError) }
            }
        }
    }
}
