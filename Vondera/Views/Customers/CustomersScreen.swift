//
//  ClientsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CustomersScreen: View {
    @StateObject var viewModel = ClientsViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            SkeltonManager(isLoading: !viewModel.intialDataLoaded, count: 12, skeltonView: ClientCardSkelton())
            
            ForEach(viewModel.filteredItems) { item in
                ClientCard(client: item)
                
                if viewModel.searchText.isBlank && viewModel.canLoadMore && viewModel.filteredItems.last?.id == item.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        loadItem()
                    }
                }
            }
        }
        .listStyle(.plain)
        .padding()
        .scrollIndicators(.hidden)
        .searchable(text: $viewModel.searchText, prompt: "Search your shoppers by name")
        .background(Color.background)
        .withEmptyView(image: .btnCustomers, text: "No one shopped from your store yet :(", count: viewModel.items.count, loading: !viewModel.intialDataLoaded)
        .withEmptySearchView(searchText: viewModel.searchText, resultCount: viewModel.result.count)
        .refreshable {
            await refreshData()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if AccessFeature.customersDataExport.canAccess() {
                        Image(.icPrint)
                            .onTapGesture {
                               //TODO
                            }
                    }
                    
                    Menu {
                        Picker("Sort Option", selection: $viewModel.sortIndex) {
                            Text("Name")
                                .tag("name")
                            
                            Text("Last Order")
                                .tag("lastOrder")
                            
                            Text("Orders Count")
                                .tag("ordersCount")
                            
                            Text("Total Spent")
                                .tag("total")
                        }
                    } label: {
                        Image(.icFilter)
                    }
                }
            }
        }
        .navigationTitle("Customers")
        .withAccessLevel(accessKey: .customersDataRead, presentation: presentationMode)
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
    NavigationStack {
        CustomersScreen()
    }
}

