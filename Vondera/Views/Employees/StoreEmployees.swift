//
//  StoreEmployees.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct StoreEmployees: View {
    @StateObject var viewModel:StoreEmployeesViewModel
    @State var contactUser:UserData?
    @State private var sheetHeight: CGFloat = .zero
    @State private var addEmployee = false

    init() {
        _viewModel = StateObject(wrappedValue: StoreEmployeesViewModel())
    }
    
    var body: some View {
        List {
            // MARK : Online Users
            if viewModel.items.filter( { $0.online ?? false } ).count > 0 {
                Section("Online Employees") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.items.filter({$0.online ?? false})) { user in
                                UserCircle(user: user)
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
            }
            
            SkeltonManager(isLoading: viewModel.isLoading, count: 6, skeltonView: EmployeeCardSkelton())
            
            if !viewModel.items.filter({$0.filter(viewModel.searchText)}).isEmpty {
                Section("All Employees") {
                    ForEach($viewModel.items.indices, id: \.self) { index in
                        if $viewModel.items[index].wrappedValue.filter(viewModel.searchText) {
                            EmployeeCard(user: viewModel.items[index])
                        }
                    }
                }
            }
            
        }
        .searchable(text: $viewModel.searchText, prompt: Text("Search \($viewModel.items.count) Employees"))
        .withEmptyViewButton(image: .btnEmployees, text: "You haven't added any team members yet !", buttonText: "Add a new member", count: viewModel.items.count, loading: viewModel.isLoading, onAction: {
            
            addEmployee.toggle()
        })
        .withEmptySearchView(searchText: viewModel.searchText, resultCount: viewModel.items.filter { $0.filter(viewModel.searchText)}.count)
        .refreshable {
            await viewModel.getData()
        }
        .toolbar {
            if let store = UserInformation.shared.user?.store {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink {
                           BannedEmployees()
                        } label: {
                            Image(.btnBan)
                        }
                        
                        Button {
                            addEmployee.toggle()
                        } label: {
                            Image(systemName: "plus.app")
                        }
                        
                    }
                    .buttonStyle(.plain)
                    .font(.title2)
                    .bold()
                }
            }
            
        }
        .sheet(item: $contactUser, content: { user in
            ContactDialog(phone: user.phone, toggle: Binding(value: $contactUser))
        })
        .navigationDestination(isPresented: $addEmployee, destination: {
            NewEmployee()
        })
        .navigationTitle("Team members")
    }
}


