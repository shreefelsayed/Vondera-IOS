//
//  StoreCateogriesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation

class StoreCategoriesViewModel : ObservableObject {
    private var store:Store
    private var categoryDao:CategoryDao
    
    @Published var loading = false
    @Published var msg:String?
    @Published var items = [Category]()
    
    
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
                DispatchQueue.main.async { [self] in
                    items[index].sortValue = index
                }
            }
            print("Updated indexs")
        } catch {
            showTosat(msg: error.localizedDescription)
        }
    }
    
    func getData() async {
        DispatchQueue.main.async {
            self.loading = true
            self.items.removeAll()
        }
        
        do {
            // --> Update the database
            let data = try await categoryDao.getAll()
            DispatchQueue.main.async {
                self.items = data
                self.loading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.showTosat(msg: error.localizedDescription)
                self.loading = false
            }
        }
    }
    
    private func showTosat(msg: String) {
        self.msg = msg
    }
}

