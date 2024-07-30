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
    @Environment(\.presentationMode) private var presentationMode

    init(user: UserData) {
        self.employee = user
        _viewModel = StateObject(wrappedValue: EmployeeProfileViewModel(userData: user))
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items) { order in
                OrderCard(order: order)
                
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
        .background(Color.background)
        .refreshable {
            await refreshData()
        }
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageWithResource(imageResource: .emptyUserOrders, msg: "This team member hasn't added any orders to your store yet !")
            }
        }
        .toolbar {
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
        .navigationTitle(employee.name)
        .withAccessLevel(accessKey: .teamMembersRead, presentation: presentationMode)
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

#Preview {
    EmployeeProfile(user: UserData.example())
}
