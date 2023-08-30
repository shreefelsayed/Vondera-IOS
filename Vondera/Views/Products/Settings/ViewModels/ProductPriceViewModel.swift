//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine

class ProductPriceViewModel : ObservableObject {
    @Published var product:Product
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    var productsDao:ProductsDao

    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    @Published var price = 0
    @Published var cost = 0

    @Published var isSaving = false
    @Published var isLoading = false

    @Published var showToast = false
    @Published var msg = ""
    
    init(product:Product) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)

        // --> Set the published values
        Task {
            await getData()
        }
    }
    
    func getData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            self.product = try await productsDao.getProduct(id: product.id)!
            self.cost = Int(product.buyingPrice)
            self.price = Int(product.price)
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func update() async {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            var map:[String:Any] = ["buyingPrice": cost, "price" : price]
            try await productsDao.update(id: product.id, hashMap: map)
            
            
            showTosat(msg: "Product cost and price changed")
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
