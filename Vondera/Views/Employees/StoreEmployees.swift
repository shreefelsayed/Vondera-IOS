//
//  StoreEmployees.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import AdvancedList

struct StoreEmployees: View {
    var storeId:String
    
    @StateObject var viewModel:StoreEmployeesViewModel
    
    init( storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreEmployeesViewModel(storeId: storeId))
    }
    
    var body: some View {
        VStack {
            if !viewModel.items.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        SearchBar(text: $viewModel.searchText, hint: "Search \($viewModel.items.count) Employees")
                        
                        ForEach(viewModel.filteredItems) { item in
                            NavigationLink(destination: EmployeeProfile(user: item)) {
                                EmployeeCard(user: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Employees 🧑‍💼")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Add", destination: NewEmployee(storeId: storeId, currentList: $viewModel.items))
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.items.isEmpty {
                EmptyMessageView(msg: "You haven't added any employees yet")
            }
        }
        
    }

}

struct StoreEmployees_Previews: PreviewProvider {
    static var previews: some View {
        StoreEmployees(storeId: "")
    }
}
