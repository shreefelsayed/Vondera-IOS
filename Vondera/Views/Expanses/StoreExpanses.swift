//
//  StoreExpanses.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AdvancedList
import AlertToast

struct StoreExpanses: View {
    var storeId:String
    @ObservedObject var viewModel:StoreExpansesViewModel
    
    init(storeId:String) {
        self.storeId = storeId
        self.viewModel = StoreExpansesViewModel(storeId: storeId)
    }
    
    var body: some View {
        VStack {
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
                NavigationLink {
                    EditExpanse()
                } label: {
                    let showLabel =  !item.date!.toDate().isSameMonth(as: viewModel.filteredItems.previousItem(of: item)?.date!.toDate())
                    ExpansesCard(expanse: item, showData: showLabel)
                }
                .mySwipeAction() { // custom color + icon
                    withAnimation {
                        viewModel.deleteItem(item: item)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }, listState: viewModel.state, emptyStateView: {
                EmptyMessageView(msg: "You haven't recorded any expanses yet !")
            }, errorStateView: { error in
                Text(error.localizedDescription).lineLimit(nil)
            }, loadingStateView: {
                ProgressView()
            }).pagination(.init(type: .thresholdItem(offset: 5), shouldLoadNextPage: {
                loadItem()
            }) {
            }).refreshable(action: {
                await refreshData()
            })
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddExpanse(storeId: storeId, currentList: $viewModel.items)) {
                    Text("Add")
                }
            }
        }
        .navigationTitle("Expanses 💳")
        .navigationBarTitleDisplayMode(.large)
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

struct StoreExpanses_Previews: PreviewProvider {
    static var previews: some View {
        StoreExpanses(storeId: "")
    }
}
