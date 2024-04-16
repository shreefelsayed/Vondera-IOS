//
//  StoreExpanses.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast


struct StoreExpanses: View {
    @State var selectedExpanse:Expense?
    @State var addExpanses = false
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel = StoreExpansesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.searchText.isBlank ? $viewModel.items : $viewModel.result) { item in
                ExpansesCard(expanse: item) {
                    withAnimation {
                        viewModel.deleteItem(item: item.wrappedValue)
                    }
                    
                } onClicked: {
                    selectedExpanse = item.wrappedValue
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
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .padding()
        
        .searchable(text: $viewModel.searchText, prompt: "Search for expanse")
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageResourceWithButton(imageResource: .emptyExpanses, msg: "You haven't recorded any expanses yet !") {
                    Button("Add a new expanse") {
                        addExpanses.toggle()
                    }
                }
            }
        }
        .toolbar {
            if let myUser = UserInformation.shared.user, myUser.canAccessAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            addExpanses.toggle()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        
                        NavigationLink {
                            ExpansesReport(storeId: myUser.storeId)
                        } label: {
                            Label("Reports", systemImage: "filemenu.and.selection")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
            
        }
        .refreshable {
            await refreshData()
        }
        .toast(isPresenting: Binding(value: $viewModel.msg), alert : {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: viewModel.msg?.toString())
        })
        .sheet(isPresented: $addExpanses, content: {
            NavigationStack {
                AddExpanse() { newValue in
                    withAnimation {
                        viewModel.items.insert(newValue, at: 0)
                    }
                }
            }
        })
        .sheet(item: $selectedExpanse) { item in
            NavigationStack {
                EditExpanse(expanse: item) { newValue in
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
        .background(Color.background)
        .navigationTitle("Expanses 💳")
        .withPaywall(accessKey: .expanses, presentation: presentationMode)

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
        StoreExpanses()

    }
}
