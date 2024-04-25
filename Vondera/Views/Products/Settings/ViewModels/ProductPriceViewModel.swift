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
    
    
    
    
    init(product:StoreProduct) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)

        // --> Set the published values
        
    }
    
}
