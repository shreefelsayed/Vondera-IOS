//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine

class ProductStocksViewModel : ObservableObject {
    @Published var product:StoreProduct
    var productsDao:ProductsDao
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    @Published var stock = 0

    @Published var isSaving = false
    @Published var isLoading = false

    @Published var showToast = false
    @Published var msg = ""
    
    init(product:StoreProduct) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)
    }
    
    func update() async {
        guard stock != 0 else {
            showTosat(msg: "Enter how many pieces you want to add")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            try await productsDao.addToStock(id: product.id, q: Double(stock))
            
            
            showTosat(msg: "Pieces added to stock")
            DispatchQueue.main.async {
                self.shouldDismissView = true
            }
        } catch {
            showTosat(msg: error.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func showTosat(msg: String) {
        self.msg = msg
        showToast.toggle()
    }
}
