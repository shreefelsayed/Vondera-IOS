//
//  StoreEmployees.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct StoreEmployees: View {
    var storeId:String
    
    @StateObject var viewModel:StoreEmployeesViewModel
    @State var contactUser:UserData?
    @State private var sheetHeight: CGFloat = .zero

    init( storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreEmployeesViewModel(storeId: storeId))
    }
    
    var body: some View {
        VStack {
            // MARK : Online Users
            if viewModel.items.filter( { $0.online ?? false } ).count > 0 {
                Text("Online Employees 🧑‍💼")
                    .font(.title2.bold())
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .center, spacing: 12) {
                        ForEach(viewModel.items.filter({$0.online ?? false})) { user in
                            UserCircle(user: user)
                        }
                    }
                }
                
                Spacer().frame(height: 20)
            }
            
            List {
                ForEach($viewModel.items.indices, id: \.self) { index in
                    if $viewModel.items[index].wrappedValue.filter(viewModel.searchText) {
                        EmployeeCard(user: viewModel.items[index])
                            .padding(.vertical)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
            .listStyle(.plain)
            
        }
        .searchable(text: $viewModel.searchText, prompt: Text("Search \($viewModel.items.count) Employees"))
        .padding()
        .navigationTitle("Employees 🧑‍💼")
        .toolbar {
            if let store = UserInformation.shared.user?.store {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add") {
                        store.employeesCount ?? 0 < store.subscribedPlan?.employeesCount ?? 0 ? 
                        AnyView(NewEmployee(storeId: storeId)) : AnyView(AppPlans(selectedSlide: 4))
                    }
                }
            }
            
        }
        .sheet(item: $contactUser, content: { user in
            ContactDialog(phone: user.phone, toggle: Binding(value: $contactUser))
        })
        .refreshable {
            await viewModel.getData()
        }
        .overlay(alignment: .center) {
            if viewModel.items.isEmpty && !viewModel.isLoading {
                EmptyMessageView(systemName: "person.crop.circle.badge.moon.fill", msg: "You haven't added any employees yet")
            }
        }
        
    }

}

struct StoreEmployees_Previews: PreviewProvider {
    static var previews: some View {
        StoreEmployees(storeId: "")
    }
}
