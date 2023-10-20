//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine

class ProductVisibiltyViewModel : ObservableObject {
    @Published var product:StoreProduct
    private var productsDao:ProductsDao
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var toogle = true
    @Published var isSaving = false
    @Published var msg:String?
    
    init(product: StoreProduct) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)
        
        toogle = product.visible ?? true
    }
    
    func update() async {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["visible": toogle]
            try await productsDao.update(id: product.id, hashMap: map)
            
            product.visible = toogle
            showTosat(msg: "Store Name Changed")
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
    }
}
