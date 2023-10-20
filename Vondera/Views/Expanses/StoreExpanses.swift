//
//  StoreExpanses.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast


struct StoreExpanses: View {
    var storeId:String
    
    @State var selectedExpanse:Expense?
    @State var addExpanses = false
    @ObservedObject var viewModel:StoreExpansesViewModel
    
    init(storeId:String) {
        self.storeId = storeId
        self.viewModel = StoreExpansesViewModel(storeId: storeId)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.searchText.isBlank ? $viewModel.items : $viewModel.result) { item in
                VStack(alignment: .center) {
                    ExpansesCard(expanse: item)
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteItem(item: item.wrappedValue)
                                }
                            } label: {
                                Image(systemName: "trash.fill")
                            }

                            Button {
                                selectedExpanse = item.wrappedValue
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .tint(.blue)
                        }
                    
                    // MARK : Loading indec
                    if viewModel.canLoadMore && viewModel.items.last?.id == item.id {
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
        }
        .searchable(text: $viewModel.searchText, prompt: "Search for expanse")
        .refreshable {
            await refreshData()
        }
        .listStyle(.plain)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(systemName: "coloncurrencysign.circle.fill", msg: "You haven't recorded any expanses yet !")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    addExpanses.toggle()
                }
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg), alert : {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: viewModel.msg)
        })
        
        .sheet(isPresented: $addExpanses, content: {
            NavigationStack {
                AddExpanse(storeId: storeId) { newValue in
                    withAnimation {
                        viewModel.items.insert(newValue, at: 0)
                    }
                }
            }
        })
        .sheet(item: $selectedExpanse) { item in
            NavigationStack {
                EditExpanse(expanse: item, storeId: storeId) { newValue in
                    let index = viewModel.items.firstIndex { $0.id == newValue.id }
                    if let index = index {
                        DispatchQueue.main.async {
                            viewModel.items[index] = newValue
                            viewModel.msg = "Updated"
                        }
                    }
                }
            }
        }

        .navigationTitle("Expanses 💳")
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
    NavigationView {
        StoreExpanses(storeId: Store.Qotoofs())

    }
}
