//
//  StoreCateogriesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import AdvancedList

class StoreCategoriesViewModel : ObservableObject {
    private var store:Store
    private var categoryDao:CategoryDao
    
    @Published var showToast = false
    @Published var msg = ""
    @Published var items = [Category]()
    @Published var listState:ListState = .items
    
    
    init(store:Store) {
        self.store = store
        categoryDao = CategoryDao(storeId: store.ownerId)
        Task {
            await getData()
        }
    }
    
    func updateIndexes() async {
        do {
            for (index, cat) in items.enumerated() {
                try await categoryDao.update(id: cat.id, hash: ["sortValue":index])
            }
        } catch {
            showTosat(msg: error.localizedDescription)
        }
    }
    
    private func getData() async {
        DispatchQueue.main.async {
            self.listState = .loading
        }
        
        do {
            print("Store id \(store.ownerId)")
            // --> Update the database
            let data = try await categoryDao.getAll()
            print("Category count \(data.count)")
            
            DispatchQueue.main.async {
                self.items = data
                self.listState = .items
            }
        } catch {
            showTosat(msg: error.localizedDescription)
            self.listState = .error(error as NSError)
        }
    }
    
    private func showTosat(msg: String) {
        self.msg = msg
        showToast.toggle()
    }
}

