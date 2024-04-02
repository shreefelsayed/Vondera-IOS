//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine

class ProductVarientsViewModel : ObservableObject {
    @Published var product:StoreProduct
    var productsDao:ProductsDao
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var isSaving = false
    @Published var msg:String?
    
    @Published var listTitles = [String]()
    @Published var listOptions = [[String]]()
    
    init(product:StoreProduct) {
        self.product = product
        productsDao = ProductsDao(storeId: product.storeId)
        setArrayData()
    }
    
    func setArrayData() {
        listOptions.removeAll()
        listTitles.removeAll()
        
        guard product.hashVarients != nil else {
            return
        }
        
        for item in product.hashVarients! {
            if let firstKey = item.keys.first, let arrayValue = item[firstKey] {
                listTitles.append(firstKey)
                listOptions.append(arrayValue)
            }
        }
    }
    
    func update() async {
        let list = listVarient()
        guard canAddVarient() else {
            showTosat(msg: "Fill the current variant first")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            let map:[String:Any] = ["hashVarients": list]
            try await productsDao.update(id: product.id, hashMap: map)
            
            DispatchQueue.main.async {
                self.showTosat(msg: "Product variants updated")
                self.shouldDismissView = true
            }
        } catch {
            showTosat(msg: error.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func deleteVarient(i:Int) {
        listTitles.remove(at: i)
        listOptions.remove(at: i)
    }
    
    func canAddVarient() -> Bool {
        if listTitles.isEmpty { return true }
        
        if listTitles.last!.isEmpty || listOptions.last!.isEmpty {
            return false
        }
        
        return true
    }
    
    func addVarient() {
        guard canAddVarient() else {
            showTosat(msg: "Fill the current variant first")
            return
        }
        
        
        listTitles.append("")
        listOptions.append([String]())
    }
    
    func listVarient() -> [[String: [String]]] {
        var listVars = [[String: [String]]]()
        for (index, title) in listTitles.enumerated() {
            listVars.append([title:listOptions[index]])
        }
        
        return listVars
    }
    
    func showTosat(msg: String) {
        self.msg = msg
    }
}
