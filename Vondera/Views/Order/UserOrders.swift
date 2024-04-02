//
//  UserOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI

struct UserOrders: View {
    @StateObject var viewModel = UserOrdersViewModel()
    
    var body: some View {
        List {
            SkeltonManager(isLoading: !viewModel.intialDataLoaded, count: 12, skeltonView: OrderCardSkelton())
            
            ForEach($viewModel.items.indices, id: \.self) { index in
                
                OrderCard(order: $viewModel.items[index])
                
                if viewModel.canLoadMore && viewModel.items.last?.id == viewModel.items[index].id && viewModel.intialDataLoaded {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await getData()
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .padding()
        .background(Color.background)
        .overlay {
            if viewModel.intialDataLoaded && viewModel.items.isEmpty {
                EmptyMessageView(msg: "You haven't added any orders yet !")
            }
        }
        .refreshable {
            await refreshData()
        }
        .navigationTitle("My Orders")
        .toolbar {
            if let user = UserInformation.shared.user {
                NavigationLink {
                    EmployeeReports(employee: user)
                } label: {
                    Image(.btnReports)
                }
            }
        }
    }
    
    func refreshData() async {
        viewModel.refreshData()
    }
    
    func getData() async {
        await viewModel.getData()
    }
}
