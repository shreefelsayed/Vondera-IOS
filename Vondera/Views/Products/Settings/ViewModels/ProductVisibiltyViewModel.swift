//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine

class ProductVisibiltyViewModel : ObservableObject {
    @Published var product:Product
    var productsDao:ProductsDao
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
    @Published var toogle = true

    @Published var isSaving = false
    @Published var isLoading = false

    @Published var showToast = false
    @Published var msg = ""
    
    init(product: Product) {
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
            self.toogle = product.visible ?? true
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
            var map:[String:Any] = ["visible": toogle]
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
        showToast.toggle()
    }
}
