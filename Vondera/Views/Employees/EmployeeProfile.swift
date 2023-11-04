//
//  EmployeeProfile.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct EmployeeProfile: View {
    
    var employee:UserData
    @StateObject var viewModel:EmployeeProfileViewModel

    init(user: UserData) {
        self.employee = user
        _viewModel = StateObject(wrappedValue: EmployeeProfileViewModel(userData: user))
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items) { order in
                OrderCard(order: order)
                    .listRowSeparator(.hidden)
                
                if viewModel.canLoadMore && viewModel.items.last?.id == order.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        loadItem()
                    }
                }
            }
        }
        .refreshable {
            await refreshData()
        }
        .listStyle(.plain)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "This user doesn't have any orders")
            }
        }
        .toolbar {
            if let myUser = UserInformation.shared.user, myUser.canAccessAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink {
                            EmployeeReports(employee: employee)
                        } label: {
                            Label("Reports", systemImage: "filemenu.and.selection")
                        }
                        
                        NavigationLink {
                            EmployeeSettings(id: employee.id)
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
        }
        .navigationTitle(employee.name)
    }
             
    func refreshData() async {
        await viewModel.refreshData()
    }
    
    func loadItem() {
        Task {
            await viewModel.getData()
        }
    }
}

struct EmployeeProfile_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeProfile(user:UserData.example())
    }
}
