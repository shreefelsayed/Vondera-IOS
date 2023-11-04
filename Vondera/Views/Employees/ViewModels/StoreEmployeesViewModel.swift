//
//  StoreEmployeesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation

class StoreEmployeesViewModel: ObservableObject {
    var storeId:String
        
    @Published var items = [UserData]()
    @Published var searchText = ""

    @Published var isLoading = false
    @Published var error = ""
    
    init(storeId:String) {
        self.storeId = storeId
        
        Task {
            await getData()
        }
    }
        
    func getData() async {
        guard !isLoading else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        

        do {
            if let uId = UserInformation.shared.user?.id {
                var data = try await UsersDao().storeEmployees(expect: uId, storeId: storeId, active: true)
                data = data.filter({ $0.accountType != "Owner" })
                DispatchQueue.main.async { [data] in
                    self.items = data
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

