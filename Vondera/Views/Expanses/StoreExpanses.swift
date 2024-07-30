//
//  StoreExpanses.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import Combine
import Foundation
import FirebaseFirestore

class StoreExpansesViewModel : ObservableObject {
    @Published var isLoading = false
    
    @Published var items = [Expense]()
    @Published var result = [Expense]()

    @Published var canLoadMore = true
    
    // --> Server search
    private var cancellables = Set<AnyCancellable>()
    @Published var searchText = ""
    
    private var lastSnapshot:DocumentSnapshot?
    
    init() {
        Task {
            await getData()
            initSearch()
        }
    }
    
    
    func deleteItem(item:Expense) {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        Task {
            try await ExpansesDao(storeId: storeId).delete(id:item.id)
            DispatchQueue.main.sync {
                ToastManager.shared.showToast(msg: "Expanses Deleted", toastType: .success)
                items.removeAll(where: { $0.id == item.id })
            }
        }
    }
    
    func refreshData() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        self.searchText = ""
        await getData()
    }
    
    func getData() async {
        guard !isLoading || !canLoadMore else {
            return
        }
        
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let result = try await ExpansesDao(storeId: storeId).getExpanses(lastSnapShot: lastSnapshot)
            DispatchQueue.main.sync {
                self.lastSnapshot = result.1
                self.items.append(contentsOf: result.0)
                if result.0.count == 0 {
                    self.canLoadMore = false
                }
                
                self.isLoading = false
            }
        } catch {
            self.isLoading = false
        }
        
    }
    
    func initSearch() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        $searchText
            .debounce(for: .seconds(1.2), scheduler: RunLoop.main) // Adjust the debounce time as needed
            .removeDuplicates() // To avoid duplicate values
            .sink { [self] newValue in
                if !newValue.isBlank {
                    Task {
                        do {
                            let result = try await ExpansesDao(storeId: storeId).search(text: searchText).sorted(by: { $0.date.toDate() < $1.date.toDate() })
                            
                            DispatchQueue.main.sync {
                                self.result = result
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}

struct StoreExpanses: View {
    @State var selectedExpanse:Expense?
    @State var addExpanses = false
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var viewModel = StoreExpansesViewModel()
    
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        addExpanses.toggle()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    
                    NavigationLink {
                        ExpansesReport(storeId: UserInformation.shared.user?.storeId ?? "")
                    } label: {
                        Label("Reports", systemImage: "filemenu.and.selection")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
        .refreshable {
            await refreshData()
        }
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
                            ToastManager.shared.showToast(msg: "Updated", toastType: .success)
                        }
                    }
                }
            }
        }
        .background(Color.background)
        .navigationTitle("Expanses 💳")
        .withAccessLevel(accessKey: .expensesRead, presentation: presentationMode)
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
