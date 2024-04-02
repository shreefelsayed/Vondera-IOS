//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine

class ProductPriceViewModel : ObservableObject {
    @Published var product:StoreProduct
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    var productsDao:ProductsDao

    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    @Published var price:Int = 0
    @Published var cost:Int = 0
    @Published var crossed:Int = 0

    @Published var isSaving = false
    @Published var isLoading = false

    @Published var msg:String?
    
    init(product:StoreProduct) {
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
            if let product = try await productsDao.getProduct(id: product.id) {
                DispatchQueue.main.async {
                    self.product = product
                    self.cost = product.buyingPrice
                    self.price = product.price
                    self.crossed = Int(product.crossedPrice ?? 0)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    
    func check() -> Bool{
        guard price != 0 else {
            msg = "Selling price can't be Zero"
            return false
        }
        
        if crossed > 0 && crossed < price {
            msg = "Crossed price can't be less than the selling price"
            return false
        }
        
        return true
    }
    
    func update() async {
        guard check() else {
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["buyingPrice": cost, "price" : price, "crossedPrice" : crossed]
            try await productsDao.update(id: product.id, hashMap: map)
            
            DispatchQueue.main.async {
                self.msg = "Product cost and price changed"
                self.shouldDismissView = true
            }
        } catch {
            msg = error.localizedDescription
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
}
