//
//  EmployeeProfile.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import AdvancedList

struct EmployeeProfile: View {
    var user:UserData
    @StateObject var viewModel:EmployeeProfileViewModel

    init(user: UserData) {
        self.user = user
        _viewModel = StateObject(wrappedValue: EmployeeProfileViewModel(userData: user))
    }
    
    var body: some View {
        AdvancedList(viewModel.items, listView: { rows in
            if #available(iOS 14, macOS 11, *) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, content: rows)
                        .padding()
                }
            } else {
                List(content: rows)
            }
        }, content: { item in
            OrderCard(order: item)
        }, emptyStateView: {
            if viewModel.isLoading == false {
               EmptyMessageView(msg: "This user doesn't have any orders")
            }
        }, errorStateView: { error in
            Text(error.localizedDescription).lineLimit(nil)
        }, loadingStateView: {
            ProgressView()
        }).pagination(.init(type: .thresholdItem(offset: 5), shouldLoadNextPage: {
            if viewModel.canLoadMore {
                loadItem()
            }
        }) {
            if viewModel.isLoading {
                ProgressView()
            }
        }).refreshable(action: {
            await refreshData()
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.myUser != nil && viewModel.myUser!.canAccessAdmin {
                    NavigationLink(destination: EmployeeSettings(id: user.id), label: {
                        Text("Settings")
                    })
                }
                
            }
        })
        .navigationTitle(user.name)
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
