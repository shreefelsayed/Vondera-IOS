//
//  StoreEmployeesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation

class StoreEmployeesViewModel: ObservableObject {
    var storeId:String
    var user:UserData?
    
    var usersDao:UsersDao = UsersDao()
    
    @Published var items = [UserData]()
    @Published var searchText = ""

    @Published var isLoading = false
    @Published var error = ""
    @Published var isRefreshing = false
        
    
    var filteredItems: [UserData] {
        guard !searchText.isEmpty else { return items }
        return items.filter { item in
            item.filter(searchText)
        }
    }
    
    
    init(storeId:String) {
        self.storeId = storeId
        
        Task {
            user = UserInformation.shared.getUser()
            await getData()
        }
    }
        
    func getData() async {
        guard !isLoading else {
            return
        }
        
        self.isLoading = true

        do {
            items = try await usersDao.storeEmployees(expect: user?.id ?? "", storeId: storeId, active: true)
        } catch {
            print(error.localizedDescription)
        }
        
        self.isLoading = false
    }
}

